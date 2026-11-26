import 'dart:async';

import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

void main() {
  group('FormArray', () {
    test('array of simple controls', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );

      tags.add();
      tags[0].value = 'Beach Tennis';

      expect(tags.length, 1);
      expect(tags.value, ['Beach Tennis']);
    });

    test('array of groups', () {
      final people = FormArray<Person, PersonForm>(create: PersonForm.new);

      people.add();
      people[0].name.value = 'Maria';
      people[0].email.value = 'maria@example.com';

      expect(people.length, 1);
      expect(people.value.single.name, 'Maria');
    });

    test('setAt replaces an item outright and disposes the old one', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );
      tags.add();
      tags[0].value = 'a';
      final old = tags[0];
      final replacement = FormControl<String>(initialValue: 'replacement');

      tags.setAt(0, replacement);

      expect(tags.length, 1);
      expect(tags[0], same(replacement));
      expect(tags.value, ['replacement']);
      expect(() => old.value = 'still alive?', throwsStateError);
    });

    test('add, insert, remove and reorder', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );

      tags.add(); // index 0
      tags[0].value = 'a';
      tags.add(); // index 1
      tags[1].value = 'b';
      tags.insert(1); // new empty item in the middle
      tags[1].value = 'c';

      expect(tags.value, ['a', 'c', 'b']);

      tags.removeAt(1);
      expect(tags.value, ['a', 'b']);

      tags.move(0, 1);
      expect(tags.value, ['b', 'a']);
    });

    test('aggregated validity considering the items', () {
      final people = FormArray<Person, PersonForm>(create: PersonForm.new);
      people.add();

      expect(people.invalid, isTrue); // name is required and empty

      people[0].name.value = 'Maria';
      expect(people.valid, isTrue);
    });

    test('changes from items propagate to the array', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );
      tags.add();

      var notifications = 0;
      tags.addListener(() => notifications++);

      tags[0].value = 'new value';
      expect(notifications, greaterThan(0));
    });

    test('removed items are disposed', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );
      tags.add();
      final removed = tags[0];

      tags.removeAt(0);

      expect(tags.length, 0);
      expect(() => removed.value = 'still alive?', throwsStateError);
    });

    test('the array\'s own validators', () {
      final people = FormArray<Person, PersonForm>(
        create: PersonForm.new,
        validators: [
          (list) => list.isEmpty
              ? const ValidationError('At least one person is required')
              : null,
        ],
      );

      expect(people.invalid, isTrue);

      people.add();
      people[0].name.value = 'Maria';
      expect(people.valid, isTrue);
    });

    test('validating aggregates up from an item with an async validator', () async {
      final completer = Completer<ValidationError?>();
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(
          initialValue: '',
          asyncValidators: [(value) => completer.future],
        ),
      );

      expect(tags.validating, isFalse); // no items yet

      tags.add();
      expect(tags.validating, isTrue);

      completer.complete(null);
      await Future<void>.delayed(Duration.zero);
      expect(tags.validating, isFalse);
    });
  });
}
