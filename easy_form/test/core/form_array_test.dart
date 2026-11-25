import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

void main() {
  group('FormArray', () {
    test('array de controles simples', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );

      tags.add();
      tags[0].value = 'Beach Tennis';

      expect(tags.length, 1);
      expect(tags.value, ['Beach Tennis']);
    });

    test('array de grupos', () {
      final people = FormArray<Person, PersonForm>(create: PersonForm.new);

      people.add();
      people[0].name.value = 'Maria';
      people[0].email.value = 'maria@example.com';

      expect(people.length, 1);
      expect(people.value.single.name, 'Maria');
    });

    test('adicionar, inserir, remover e reordenar', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );

      tags.add(); // index 0
      tags[0].value = 'a';
      tags.add(); // index 1
      tags[1].value = 'b';
      tags.insert(1); // novo item vazio no meio
      tags[1].value = 'c';

      expect(tags.value, ['a', 'c', 'b']);

      tags.removeAt(1);
      expect(tags.value, ['a', 'b']);

      tags.move(0, 1);
      expect(tags.value, ['b', 'a']);
    });

    test('validade agregada considerando os itens', () {
      final people = FormArray<Person, PersonForm>(create: PersonForm.new);
      people.add();

      expect(people.invalid, isTrue); // name obrigatório e vazio

      people[0].name.value = 'Maria';
      expect(people.valid, isTrue);
    });

    test('propagação de alterações dos itens para o array', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );
      tags.add();

      var notifications = 0;
      tags.addListener(() => notifications++);

      tags[0].value = 'novo valor';
      expect(notifications, greaterThan(0));
    });

    test('descarte de itens removidos', () {
      final tags = FormArray<String, FormControl<String>>(
        create: () => FormControl<String>(initialValue: ''),
      );
      tags.add();
      final removed = tags[0];

      tags.removeAt(0);

      expect(tags.length, 0);
      expect(() => removed.value = 'ainda vivo?', throwsStateError);
    });

    test('validators próprios do array', () {
      final people = FormArray<Person, PersonForm>(
        create: PersonForm.new,
        validators: [
          (list) => list.isEmpty
              ? const ValidationError('Precisa de ao menos uma pessoa')
              : null,
        ],
      );

      expect(people.invalid, isTrue);

      people.add();
      people[0].name.value = 'Maria';
      expect(people.valid, isTrue);
    });
  });
}
