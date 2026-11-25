import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormControl', () {
    test('valor inicial e valor atualizado', () {
      final control = FormControl<String>(initialValue: 'Maria');
      expect(control.value, 'Maria');

      control.value = 'João';
      expect(control.value, 'João');
    });

    test('nulabilidade: T? aceita ausência de initialValue', () {
      final control = FormControl<String?>();
      expect(control.value, isNull);
    });

    test('nulabilidade: T não-nulável exige initialValue', () {
      expect(() => FormControl<String>(), throwsArgumentError);
    });

    test('dirty e pristine', () {
      final control = FormControl<String>(initialValue: 'a');
      expect(control.pristine, isTrue);
      expect(control.dirty, isFalse);

      control.value = 'b';
      expect(control.dirty, isTrue);
      expect(control.pristine, isFalse);
    });

    test('touched e untouched', () {
      final control = FormControl<String>(initialValue: 'a');
      expect(control.untouched, isTrue);

      control.markAsTouched();
      expect(control.touched, isTrue);
      expect(control.untouched, isFalse);
    });

    test('validators e erros', () {
      final control = FormControl<String>(
        initialValue: '',
        validators: [Validators.required, Validators.minLength(3)],
      );

      expect(control.invalid, isTrue);
      expect(control.errors, contains(const ValidationError('Campo obrigatório', code: 'required')));

      control.value = 'ab';
      expect(control.errors.single.code, 'minLength');

      control.value = 'abc';
      expect(control.valid, isTrue);
    });

    test('reset restaura valor inicial, pristine e untouched', () {
      final control = FormControl<String>(initialValue: 'a');
      control.value = 'b';
      control.markAsTouched();

      control.reset();

      expect(control.value, 'a');
      expect(control.pristine, isTrue);
      expect(control.untouched, isTrue);
    });

    test('desabilitar remove os erros, habilitar os traz de volta', () {
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

    test('notifica listeners ao alterar o valor', () {
      final control = FormControl<String>(initialValue: 'a');
      var notifications = 0;
      control.addListener(() => notifications++);

      control.value = 'b';
      expect(notifications, 1);

      // Mesmo valor não deve gerar notificação duplicada.
      control.value = 'b';
      expect(notifications, 1);
    });
  });
}
