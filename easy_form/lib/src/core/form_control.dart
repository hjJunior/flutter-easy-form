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
  }) : initialValue = initialValue ?? _fallbackValue<T>() {
    _value = this.initialValue;
  }

  /// The value this control is restored to by [reset].
  final T initialValue;

  final List<Validator<T>> validators;

  late T _value;

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    markAsDirty();
    notifyListeners();
  }

  @override
  List<ValidationError> get errors {
    if (disabled) return const [];
    return [
      for (final validator in validators)
        if (validator(_value) case final error?) error,
    ];
  }

  @override
  void reset() {
    _value = initialValue;
    super.reset();
  }

  static T _fallbackValue<T>() {
    if (null is T) return null as T;
    throw ArgumentError(
      'FormControl<$T>: initialValue is required because $T is non-nullable. '
      'Pass an initialValue, or declare the control as FormControl<$T?>.',
    );
  }
}
