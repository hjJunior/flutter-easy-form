import 'dart:async';

import '../validation/validation_error.dart';
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
  /// whether a username is taken). Run on construction, whenever
  /// [value] changes, on [reset], and on [validate]; [validating] is
  /// true while any of them is in flight, and their errors join
  /// [validators]' own in [errors] once they resolve. One that throws or
  /// times out instead is reflected by [hasFailedValidation], not
  /// [errors] — see that getter.
  final List<AsyncValidator<T>> asyncValidators;

  late T _value;
  List<ValidationError> _asyncErrors = const [];
  bool _validating = false;
  bool _validationFailed = false;
  int _validationRun = 0;
  bool _disposed = false;

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    markAsDirty();
    unawaited(_runAsyncValidators());
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

  @override
  Future<void> validate() async {
    await super.validate(); // marks touched; no children to await
    await _runAsyncValidators();
  }

  @override
  void reset() {
    _value = initialValue;
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
    super.dispose();
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
