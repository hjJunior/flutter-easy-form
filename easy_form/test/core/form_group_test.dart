import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

void main() {
  group('FormGroup', () {
    test('composes controls, accessed directly as properties', () {
      final form = PersonForm();
      form.name.value = 'Maria';
      form.email.value = 'maria@example.com';

      expect(form.toValue(), isA<Person>());
      expect(form.value.name, 'Maria');
      expect(form.value.email, 'maria@example.com');
    });

    test('toValue() is best-effort: it never checks valid or throws', () {
      final form = PersonForm(); // name is required and still empty
      expect(form.invalid, isTrue);

      final person = form.toValue();

      expect(person.name, '');
      expect(person.email, '');
    });

    test('aggregated validity: a group is invalid if any child is invalid', () {
      final form = PersonForm();
      expect(form.invalid, isTrue); // name is required and empty

      form.name.value = 'Maria';
      expect(form.valid, isTrue);
    });

    test('changes propagate up to the group', () {
      final form = PersonForm();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.name.value = 'Maria';
      expect(notifications, greaterThan(0));
    });

    test('markAsTouched propagates to the children', () {
      final form = PersonForm();
      expect(form.untouched, isTrue);

      form.markAsTouched();

      expect(form.name.touched, isTrue);
      expect(form.email.touched, isTrue);
    });

    test('markAsInitial cascades to children and rebases reset()', () {
      final form = PersonForm();
      form.name.value = 'Maria';
      expect(form.dirty, isTrue);

      form.markAsInitial();
      expect(form.dirty, isFalse);
      expect(form.name.initialValue, 'Maria');

      form.name.value = 'Someone else';
      form.reset();
      expect(form.name.value, 'Maria');
    });

    test('disabling the group disables its children in cascade', () {
      final form = PersonForm();
      form.disable();

      expect(form.name.disabled, isTrue);
      expect(form.email.disabled, isTrue);
      expect(form.valid, isTrue); // no errors while disabled
    });

    test('recursive validation and reset', () {
      final form = ArenaForm();
      form.contacts.add();
      form.contacts[0].name.value = 'Maria';
      form.name.value = 'Central Arena';

      expect(form.dirty, isTrue);
      expect(form.contacts[0].dirty, isTrue);

      form.reset();

      expect(form.name.value, '');
      expect(form.pristine, isTrue);
      expect(form.contacts[0].name.value, '');
      expect(form.contacts[0].pristine, isTrue);
    });

    test('validateSelf (own level): a rule between the group\'s own fields', () {
      final form = ArenaForm();
      form.name.value = 'Central Arena';
      form.international.value = true;

      expect(form.invalid, isTrue);
      expect(
        form.errors,
        contains(const ValidationError(
          'An international arena requires at least one contact',
          code: 'international_arena_requires_contact',
        )),
      );

      form.contacts.add();
      form.contacts[0].name.value = 'Maria';
      form.contacts[0].email.value = 'maria@example.com';
      expect(form.valid, isTrue);
    });

    test('validateSelf can report more than one violation at once', () {
      final form = ArenaForm();
      form.international.value = true; // name is empty and there are no contacts

      final codes = form.errors.map((error) => error.code).toSet();
      expect(codes, containsAll(['international_arena_requires_name', 'international_arena_requires_contact']));
    });

    test('validateSelf (nested level): reaches the root via context with no casts', () {
      final form = ArenaForm();
      form.international.value = true;
      form.contacts.add();
      form.contacts[0].name.value = 'Maria';

      // empty email + international arena (read via context.root) -> invalid
      expect(form.contacts[0].invalid, isTrue);
      expect(form.contacts[0].errors.single.code, 'email_required_for_international_arena');

      form.contacts[0].email.value = 'maria@example.com';
      expect(form.contacts[0].valid, isTrue);

      // The same contact is valid when the arena is not international.
      form.international.value = false;
      form.contacts[0].email.value = '';
      expect(form.contacts[0].valid, isTrue);
    });

    test('validationErrors keeps each error tied to the node that reported it', () {
      final form = ArenaForm();
      form.international.value = true;
      form.contacts.add();
      // form.name, contacts[0].name and contacts[0].email are all left empty

      final map = form.validationErrors;

      expect(map[form], [
        const ValidationError(
          'An international arena must have a name',
          code: 'international_arena_requires_name',
        ),
      ]); // contacts.length is 1 now, so the "requires a contact" rule no longer fires

      expect(
        map[form.contacts[0].name],
        [const ValidationError('Required field', code: 'required')],
      );

      expect(map[form.contacts[0]], [
        const ValidationError(
          'Email is required for contacts of international arenas',
          code: 'email_required_for_international_arena',
        ),
      ]);

      expect(map.containsKey(form.contacts), isFalse); // no error of its own to report
    });

    test('the root group\'s context points to itself and is stable across reads', () {
      final form = ArenaForm();
      expect(form.context.root, same(form));
      expect(form.context, same(form.context));
    });
  });
}
