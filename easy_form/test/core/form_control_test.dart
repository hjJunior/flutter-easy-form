import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormControl', () {
    test('initial value and updated value', () {
      final control = FormControl<String>(initialValue: 'Maria');
      expect(control.value, 'Maria');

      control.value = 'John';
      expect(control.value, 'John');
    });

    test('nullability: T? accepts a missing initialValue', () {
      final control = FormControl<String?>();
      expect(control.value, isNull);
    });

    test('nullability: non-nullable T requires initialValue', () {
      expect(() => FormControl<String>(), throwsArgumentError);
    });

    test('dirty and pristine', () {
      final control = FormControl<String>(initialValue: 'a');
      expect(control.pristine, isTrue);
      expect(control.dirty, isFalse);

      control.value = 'b';
      expect(control.dirty, isTrue);
      expect(control.pristine, isFalse);
    });

    test('touched and untouched', () {
      final control = FormControl<String>(initialValue: 'a');
      expect(control.untouched, isTrue);

      control.markAsTouched();
      expect(control.touched, isTrue);
      expect(control.untouched, isFalse);
    });

    test('validators and errors', () {
      final control = FormControl<String>(
        initialValue: '',
        validators: [Validators.required, Validators.minLength(3)],
      );

      expect(control.invalid, isTrue);
      expect(control.errors, contains(const ValidationError('Required field', code: 'required')));

      control.value = 'ab';
      expect(control.errors.single.code, 'minLength');

      control.value = 'abc';
      expect(control.valid, isTrue);
    });

    test('reset restores the initial value, pristine and untouched', () {
      final control = FormControl<String>(initialValue: 'a');
      control.value = 'b';
      control.markAsTouched();

      control.reset();

      expect(control.value, 'a');
      expect(control.pristine, isTrue);
      expect(control.untouched, isTrue);
    });

    test('disabling clears the errors, enabling brings them back', () {
      final control = FormControl<String>(
        initialValue: '',
        validators: [Validators.required],
      );
      expect(control.invalid, isTrue);

      control.disable();
      expect(control.errors, isEmpty);
      expect(control.valid, isTrue);

      control.enable();
      expect(control.invalid, isTrue);
    });

    test('notifies listeners when the value changes', () {
      final control = FormControl<String>(initialValue: 'a');
      var notifications = 0;
      control.addListener(() => notifications++);

      control.value = 'b';
      expect(notifications, 1);

      // Setting the same value again should not notify twice.
      control.value = 'b';
      expect(notifications, 1);
    });
  });
}
