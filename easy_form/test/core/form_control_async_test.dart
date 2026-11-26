import 'dart:async';

import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormControl async validators', () {
    test('validating is true while the validator is running, false once it resolves', () async {
      final completer = Completer<ValidationError?>();
      final control = FormControl<String>(
        initialValue: '',
        asyncValidators: [(value) => completer.future],
      );

      expect(control.validating, isTrue);

      completer.complete(null);
      await Future<void>.delayed(Duration.zero);

      expect(control.validating, isFalse);
    });

    test('an async error joins errors once resolved', () async {
      final completer = Completer<ValidationError?>();
      final control = FormControl<String>(
        initialValue: 'taken',
        asyncValidators: [(value) => completer.future],
      );

      expect(control.errors, isEmpty); // still validating, nothing to report yet

      completer.complete(const ValidationError('Already taken', code: 'taken'));
      await Future<void>.delayed(Duration.zero);

      expect(control.validating, isFalse);
      expect(control.errors, contains(const ValidationError('Already taken', code: 'taken')));
    });

    test('a stale run\'s result is discarded once a newer one has started', () async {
      final completers = [Completer<ValidationError?>(), Completer<ValidationError?>()];
      var call = 0;

      final control = FormControl<String>(
        initialValue: '',
        asyncValidators: [(value) => completers[call++].future],
      );
      // construction consumed completers[0]

      control.value = 'b'; // consumes completers[1], supersedes the first run

      // Resolve the stale first run after the second has already started.
      completers[0].complete(const ValidationError('stale', code: 'stale'));
      await Future<void>.delayed(Duration.zero);
      expect(control.validating, isTrue); // the second run hasn't resolved yet
      expect(control.errors, isEmpty); // the stale result was ignored

      completers[1].complete(const ValidationError('fresh', code: 'fresh'));
      await Future<void>.delayed(Duration.zero);
      expect(control.validating, isFalse);
      expect(control.errors, contains(const ValidationError('fresh', code: 'fresh')));
    });

    test('reset() invalidates any in-flight validation', () async {
      final completers = [
        Completer<ValidationError?>(),
        Completer<ValidationError?>(),
        Completer<ValidationError?>(),
      ];
      var call = 0;

      final control = FormControl<String>(
        initialValue: 'a',
        asyncValidators: [(value) => completers[call++].future],
      );
      // run 1 (construction, value 'a') is validating

      control.value = 'b'; // run 2, supersedes run 1
      control.reset(); // back to 'a', run 3, supersedes run 2

      completers[0].complete(const ValidationError('from run 1', code: 'run1'));
      completers[1].complete(const ValidationError('from run 2', code: 'run2'));
      await Future<void>.delayed(Duration.zero);

      expect(control.value, 'a');
      expect(control.validating, isTrue); // run 3 is still unresolved
      expect(control.errors, isEmpty); // runs 1 and 2 were discarded as stale

      completers[2].complete(const ValidationError('from run 3', code: 'run3'));
      await Future<void>.delayed(Duration.zero);

      expect(control.validating, isFalse);
      expect(control.errors, contains(const ValidationError('from run 3', code: 'run3')));
    });

    test('resolving after dispose does not throw', () async {
      final completer = Completer<ValidationError?>();
      final control = FormControl<String>(
        initialValue: '',
        asyncValidators: [(value) => completer.future],
      );

      control.dispose();
      completer.complete(const ValidationError('too late', code: 'late'));

      await Future<void>.delayed(Duration.zero);
    });

    test('a validator that throws sets hasFailedValidation, not errors', () async {
      final control = FormControl<String>(
        initialValue: '',
        asyncValidators: [(value) => Future<ValidationError?>.error('boom')],
      );

      await Future<void>.delayed(Duration.zero);

      expect(control.validating, isFalse);
      expect(control.hasFailedValidation, isTrue);
      expect(control.errors, isEmpty); // a failed check is not "this value is wrong"
      expect(control.canSubmit, isFalse); // but it does block submitting
    });

    test('a later successful run clears hasFailedValidation', () async {
      var shouldThrow = true;
      final control = FormControl<String>(
        initialValue: '',
        asyncValidators: [
          (value) async {
            if (shouldThrow) throw 'boom';
            return null;
          },
        ],
      );
      await Future<void>.delayed(Duration.zero);
      expect(control.hasFailedValidation, isTrue);

      shouldThrow = false;
      control.value = 'retry';
      await Future<void>.delayed(Duration.zero);

      expect(control.hasFailedValidation, isFalse);
      expect(control.canSubmit, isTrue);
    });

    test('canSubmit is false while validating and true once settled', () async {
      final completer = Completer<ValidationError?>();
      final control = FormControl<String>(
        initialValue: '',
        asyncValidators: [(value) => completer.future],
      );

      expect(control.canSubmit, isFalse);

      completer.complete(null);
      await Future<void>.delayed(Duration.zero);

      expect(control.canSubmit, isTrue);
    });

    test('validate() awaits the async validator before resolving', () async {
      final control = FormControl<String>(
        initialValue: 'taken',
        asyncValidators: [
          (value) => Future.delayed(
                const Duration(milliseconds: 1),
                () => const ValidationError('Already taken', code: 'taken'),
              ),
        ],
      );

      await control.validate();

      expect(control.validating, isFalse);
      expect(control.errors, contains(const ValidationError('Already taken', code: 'taken')));
    });
  });
}
