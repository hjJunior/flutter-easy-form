import 'dart:async';

import '../validation/validation_error.dart';
import '../validation/validation_mode.dart';
import '../validation/validator.dart';
import 'form_node.dart';

/// A single typed value in the form tree.
///
/// Nullability of `T` is respected directly through Dart's type system:
/// `FormControl<String>` requires [initialValue] because `String` cannot
/// hold `null`; `FormControl<String?>` does not, and defaults to `null`.
class FormControl<T> extends FormNode<T> {
  FormControl({
    T? initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncValidationDebounce = const Duration(milliseconds: 400),
  }) : _initialValue = initialValue ?? _fallbackValue<T>() {
    _value = _initialValue;
    unawaited(_runAsyncValidators());
  }

  T _initialValue;

  /// The value this control is restored to by [reset] — initially the
  /// value passed to the constructor, until [markAsInitial] rebases it.
  T get initialValue => _initialValue;

  final List<Validator<T>> validators;

  /// Checks that can't complete synchronously (e.g. asking an API
  /// whether a username is taken). When they actually run is governed
  /// by [validationMode] — see that enum; [validating] is true while
  /// any of them is in flight, and their errors join [validators]' own
  /// in [errors] once they resolve. One that throws or times out
  /// instead is reflected by [hasFailedValidation], not [errors] — see
  /// that getter.
  final List<AsyncValidator<T>> asyncValidators;

  /// How long to wait after the last edit before actually running
  /// [asyncValidators], in [ValidationMode.onUserInteraction] and, once
  /// graduated, [ValidationMode.afterFirstUnfocus] — the two modes that
  /// would otherwise fire them on every keystroke. Irrelevant for a
  /// control with no async validators, and for [ValidationMode.manual]
  /// / [ValidationMode.onUnfocus], which only ever run them at an
  /// explicit check point (submit, or unfocus-after-edit).
  final Duration asyncValidationDebounce;

  late T _value;
  List<ValidationError> _asyncErrors = const [];
  bool _validating = false;
  bool _validationFailed = false;
  int _validationRun = 0;
  bool _disposed = false;

  // Validation-mode bookkeeping (see `validationMode` and the "When
  // validation runs" doc section).
  bool _editedSinceLastCheck = false;
  bool _graduatedToLive = false; // afterFirstUnfocus, once checked once
  Timer? _debounceTimer;

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    markAsDirty();
    _editedSinceLastCheck = true;
    _onEdited();
    notifyListeners();
  }

  @override
  bool get validating => _validating;

  @override
  bool get hasFailedValidation => _validationFailed;

  @override
  List<ValidationError> get ownErrors => [
        for (final validator in validators)
          if (validator(_value) case final error?) error,
        ..._asyncErrors,
      ];

  /// Call when this control's field loses focus after being interacted
  /// with — a bound `FormControlTextSync` does this for you
  /// automatically; a custom picker or dropdown that manages its own
  /// focus calls this itself once its interaction ends. A no-op unless
  /// [value] actually changed since the last check: tabbing through a
  /// field, or leaving it unchanged, costs nothing. Only meaningful for
  /// [ValidationMode.onUnfocus] and [ValidationMode.afterFirstUnfocus] —
  /// a no-op in the other two modes.
  void handleUnfocus() {
    if (!_editedSinceLastCheck) return;
    _editedSinceLastCheck = false;

    switch (validationMode) {
      case ValidationMode.onUnfocus:
        markAsTouched();
        unawaited(_runAsyncValidators());
      case ValidationMode.afterFirstUnfocus:
        markAsTouched();
        _graduatedToLive = true;
        unawaited(_runAsyncValidators());
      case ValidationMode.manual:
      case ValidationMode.onUserInteraction:
        break;
    }
  }

  @override
  Future<void> validate() async {
    _cancelDebounce();
    await super.validate(); // marks touched; no children to await
    await _runAsyncValidators();
  }

  @override
  void reset() {
    _value = initialValue;
    _editedSinceLastCheck = false;
    _graduatedToLive = false;
    _cancelDebounce();
    unawaited(_runAsyncValidators());
    super.reset();
  }

  @override
  void markAsInitial() {
    _initialValue = _value;
    super.markAsInitial();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelDebounce();
    super.dispose();
  }

  /// Reacts to an edit according to [validationMode]: reveals (and
  /// schedules the async check for) the field right away in
  /// [ValidationMode.onUserInteraction] and, once graduated,
  /// [ValidationMode.afterFirstUnfocus]; stays quiet — hiding whatever
  /// was shown for the old value — in [ValidationMode.manual] and
  /// [ValidationMode.onUnfocus] (and in [ValidationMode.afterFirstUnfocus]
  /// before its first check), which only check on an explicit submit or
  /// unfocus.
  void _onEdited() {
    switch (validationMode) {
      case ValidationMode.manual:
      case ValidationMode.onUnfocus:
        clearTouched();
        _cancelDebounce();
      case ValidationMode.onUserInteraction:
        markAsTouched();
        _scheduleDebouncedValidation();
      case ValidationMode.afterFirstUnfocus:
        if (_graduatedToLive) {
          markAsTouched();
          _scheduleDebouncedValidation();
        } else {
          clearTouched();
          _cancelDebounce();
        }
    }
  }

  void _scheduleDebouncedValidation() {
    if (asyncValidators.isEmpty) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(asyncValidationDebounce, () {
      unawaited(_runAsyncValidators());
    });
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Starts a fresh run of [asyncValidators] against the current [value].
  ///
  /// A run superseded by a later one (the value changed again, or this
  /// control reset, before it resolved) is discarded on completion — its
  /// result no longer matches the live value, so neither [_asyncErrors]
  /// nor [_validationFailed] must reflect it.
  ///
  /// A validator that throws or times out doesn't become a
  /// [ValidationError] — that would read as "this value is wrong", when
  /// really the check itself failed — it only sets
  /// [FormNode.hasFailedValidation], for a form-level banner instead of
  /// a per-field message.
  Future<void> _runAsyncValidators() async {
    final runId = ++_validationRun;

    if (asyncValidators.isEmpty) {
      _validating = false;
      _validationFailed = false;
      _asyncErrors = const [];
      return;
    }

    _validating = true;
    _validationFailed = false;
    _asyncErrors = const [];
    final value = _value;

    try {
      final results = await Future.wait(asyncValidators.map((validator) => validator(value)));
      if (_disposed || runId != _validationRun) return;
      _asyncErrors = [for (final result in results) if (result != null) result];
      _validating = false;
      notifyListeners();
    } catch (_) {
      if (_disposed || runId != _validationRun) return;
      _validationFailed = true;
      _validating = false;
      notifyListeners();
    }
  }

  static T _fallbackValue<T>() {
    if (null is T) return null as T;
    throw ArgumentError(
      'FormControl<$T>: initialValue is required because $T is non-nullable. '
      'Pass an initialValue, or declare the control as FormControl<$T?>.',
    );
  }
}
