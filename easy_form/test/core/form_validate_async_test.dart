import 'dart:async';

import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

class _AsyncGroup extends FormGroup<String, _AsyncGroup> {
  _AsyncGroup(Completer<ValidationError?> completer)
      : field = FormControl<String>(initialValue: '', asyncValidators: [(_) => completer.future]);

  final FormControl<String> field;

  @override
  Iterable<FormNode<Object?>> get children => [field];

  @override
  String toValue() => field.value;
}

void main() {
  group('FormNode.validate() recursion', () {
    test('a FormGroup awaits a nested FormControl\'s async validator', () async {
      final completer = Completer<ValidationError?>();
      final group = _AsyncGroup(completer);

      final future = group.validate();
      expect(group.validating, isTrue);

      completer.complete(const ValidationError('late', code: 'late'));
      await future;

      expect(group.validating, isFalse);
      expect(group.errors, contains(const ValidationError('late', code: 'late')));
    });

    test('a FormArray awaits every item\'s async validator', () async {
      final completers = [Completer<ValidationError?>(), Completer<ValidationError?>()];
      var next = 0;
      final array = FormArray<String, FormControl<String>>(
        create: () {
          final completer = completers[next++];
          return FormControl<String>(initialValue: '', asyncValidators: [(_) => completer.future]);
        },
      );
      array.add();
      array.add();

      final future = array.validate();
      expect(array.validating, isTrue);

      completers[0].complete(null);
      await Future<void>.delayed(Duration.zero);
      expect(array.validating, isTrue); // the second item hasn't resolved yet

      completers[1].complete(const ValidationError('late', code: 'late'));
      await future;

      expect(array.validating, isFalse);
      expect(array.errors, contains(const ValidationError('late', code: 'late')));
    });
  });
}
