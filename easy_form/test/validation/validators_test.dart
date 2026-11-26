import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('required', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('  '), isNotNull);
      expect(Validators.required('ok'), isNull);
      expect(Validators.required(0), isNull);
    });

    test('minLength and maxLength', () {
      expect(Validators.minLength(3)('ab'), isNotNull);
      expect(Validators.minLength(3)('abc'), isNull);
      expect(Validators.maxLength(3)('abcd'), isNotNull);
      expect(Validators.maxLength(3)('abc'), isNull);
    });

    test('min and max', () {
      expect(Validators.min(10)(5), isNotNull);
      expect(Validators.min(10)(10), isNull);
      expect(Validators.max(10)(11), isNotNull);
      expect(Validators.max(10)(10), isNull);
    });

    test('email', () {
      expect(Validators.email('invalid'), isNotNull);
      expect(Validators.email('name@domain.com'), isNull);
    });

    test('pattern', () {
      final onlyDigits = Validators.pattern(RegExp(r'^\d+$'), message: 'digits only');
      expect(onlyDigits('abc'), isNotNull);
      expect(onlyDigits('123'), isNull);
    });

    test('custom', () {
      final even = Validators.custom<int>(
        (value) => value.isEven ? null : const ValidationError('must be even'),
      );
      expect(even(3), isNotNull);
      expect(even(4), isNull);
    });
  });
}
