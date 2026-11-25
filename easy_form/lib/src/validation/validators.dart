import 'validation_error.dart';
import 'validator.dart';

/// Common, ready-to-use validators.
///
/// Validators here are written against the widest type that makes sense
/// (e.g. [required] takes `Object?`), which lets them be used for any
/// `FormControl<T>` whose `T` is compatible, thanks to Dart's contravariant
/// function subtyping — no generic type argument needs to be passed.
class Validators {
  const Validators._();

  static ValidationError? required(Object? value) {
    if (value == null) {
      return const ValidationError('Campo obrigatório', code: 'required');
    }
    if (value is String && value.trim().isEmpty) {
      return const ValidationError('Campo obrigatório', code: 'required');
    }
    return null;
  }

  static Validator<String> minLength(int min) {
    return (value) {
      if (value.length < min) {
        return ValidationError('Deve ter ao menos $min caracteres', code: 'minLength');
      }
      return null;
    };
  }

  static Validator<String> maxLength(int max) {
    return (value) {
      if (value.length > max) {
        return ValidationError('Deve ter no máximo $max caracteres', code: 'maxLength');
      }
      return null;
    };
  }

  static Validator<num> min(num min) {
    return (value) {
      if (value < min) {
        return ValidationError('O valor mínimo é $min', code: 'min');
      }
      return null;
    };
  }

  static Validator<num> max(num max) {
    return (value) {
      if (value > max) {
        return ValidationError('O valor máximo é $max', code: 'max');
      }
      return null;
    };
  }

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static ValidationError? email(String value) {
    if (!_emailPattern.hasMatch(value)) {
      return const ValidationError('E-mail inválido', code: 'email');
    }
    return null;
  }

  static Validator<String> pattern(RegExp regExp, {String message = 'Formato inválido'}) {
    return (value) {
      if (!regExp.hasMatch(value)) {
        return ValidationError(message, code: 'pattern');
      }
      return null;
    };
  }

  /// Identity helper so a custom validator reads consistently with the
  /// others at the call site, e.g. `Validators.custom(myRule)`.
  static Validator<T> custom<T>(Validator<T> validator) => validator;
}
