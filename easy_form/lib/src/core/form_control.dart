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
    _runAsyncValidators();
  }

  T _initialValue;

  /// The value this control is restored to by [reset] — initially the
  /// value passed to the constructor, until [markAsInitial] rebases it.
  T get initialValue => _initialValue;

  final List<Validator<T>> validators;

  /// Checks that can't complete synchronously (e.g. asking an API
  /// whether a username is taken). Run on construction, whenever
  /// [value] changes, on [reset], and on [validate]; [pending] is true
  /// while any of them is in flight, and their errors join [validators]'
  /// own in [errors] once they resolve.
  final List<AsyncValidator<T>> asyncValidators;

  late T _value;
  List<ValidationError> _asyncErrors = const [];
  bool _pending = false;
  int _validationRun = 0;
  bool _disposed = false;

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    markAsDirty();
    _runAsyncValidators();
    notifyListeners();
  }

  @override
  bool get pending => _pending;

  @override
  List<ValidationError> get errors {
    if (disabled) return const [];
    return [
      for (final validator in validators)
        if (validator(_value) case final error?) error,
      ..._asyncErrors,
    ];
  }

  @override
  void validate() {
    _runAsyncValidators();
    super.validate();
  }

  @override
  void reset() {
    _value = initialValue;
    _runAsyncValidators();
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
  /// A run superseded by a later one (the value changed again, or this
  /// control reset, before it resolved) is discarded on completion — its
  /// result no longer matches the live value, so [_asyncErrors] must not
  /// reflect it.
  void _runAsyncValidators() {
    final runId = ++_validationRun;

    if (asyncValidators.isEmpty) {
      _pending = false;
      _asyncErrors = const [];
      return;
    }

    _pending = true;
    final value = _value;
    Future.wait(asyncValidators.map((validator) => validator(value))).then((results) {
      if (_disposed || runId != _validationRun) return;
      _asyncErrors = [for (final result in results) if (result != null) result];
      _pending = false;
      notifyListeners();
    });
  }

  static T _fallbackValue<T>() {
    if (null is T) return null as T;
    throw ArgumentError(
      'FormControl<$T>: initialValue is required because $T is non-nullable. '
      'Pass an initialValue, or declare the control as FormControl<$T?>.',
    );
  }
}
