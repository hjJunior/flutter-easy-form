import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

void main() {
  group('FormGroup', () {
    test('composição de controles, acesso direto por propriedade', () {
      final form = PersonForm();
      form.name.value = 'Maria';
      form.email.value = 'maria@example.com';

      expect(form.toValue(), isA<Person>());
      expect(form.value.name, 'Maria');
      expect(form.value.email, 'maria@example.com');
    });

    test('validade agregada: grupo é inválido se algum filho for inválido', () {
      final form = PersonForm();
      expect(form.invalid, isTrue); // name obrigatório e vazio

      form.name.value = 'Maria';
      expect(form.valid, isTrue);
    });

    test('propagação de alterações até o grupo', () {
      final form = PersonForm();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.name.value = 'Maria';
      expect(notifications, greaterThan(0));
    });

    test('markAsTouched se propaga para os filhos', () {
      final form = PersonForm();
      expect(form.untouched, isTrue);

      form.markAsTouched();

      expect(form.name.touched, isTrue);
      expect(form.email.touched, isTrue);
    });

    test('desabilitar o grupo desabilita os filhos em cascata', () {
      final form = PersonForm();
      form.disable();

      expect(form.name.disabled, isTrue);
      expect(form.email.disabled, isTrue);
      expect(form.valid, isTrue); // sem erros enquanto desabilitado
    });

    test('validação e reset recursivos', () {
      final form = ArenaForm();
      form.contacts.add();
      form.contacts[0].name.value = 'Maria';
      form.name.value = 'Arena Central';

      expect(form.dirty, isTrue);
      expect(form.contacts[0].dirty, isTrue);

      form.reset();

      expect(form.name.value, '');
      expect(form.pristine, isTrue);
      expect(form.contacts[0].name.value, '');
      expect(form.contacts[0].pristine, isTrue);
    });

    test('validateSelf (próprio nível): regra entre os campos do grupo', () {
      final form = ArenaForm();
      form.international.value = true;

      expect(form.invalid, isTrue);
      expect(
        form.errors,
        contains(const ValidationError(
          'Arena internacional precisa de ao menos um contato',
          code: 'international_arena_requires_contact',
        )),
      );

      form.contacts.add();
      form.contacts[0].name.value = 'Maria';
      form.contacts[0].email.value = 'maria@example.com';
      expect(form.valid, isTrue);
    });

    test('validateSelf (nível aninhado): acessa o root via context sem casts', () {
      final form = ArenaForm();
      form.international.value = true;
      form.contacts.add();
      form.contacts[0].name.value = 'Maria';

      // email vazio + arena internacional (lido via context.root) -> inválido
      expect(form.contacts[0].invalid, isTrue);
      expect(form.contacts[0].errors.single.code, 'email_required_for_international_arena');

      form.contacts[0].email.value = 'maria@example.com';
      expect(form.contacts[0].valid, isTrue);

      // Mesmo contato é válido quando a arena não é internacional.
      form.international.value = false;
      form.contacts[0].email.value = '';
      expect(form.contacts[0].valid, isTrue);
    });

    test('context do grupo raiz aponta para si mesmo e é estável entre acessos', () {
      final form = ArenaForm();
      expect(form.context.root, same(form));
      expect(form.context, same(form.context));
    });
  });
}
