import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidationMode', () {
    test('defaults to manual', () {
      final control = FormControl<String>(initialValue: '');
      expect(control.validationMode, ValidationMode.manual);
    });

    test('is inherited from the parent, overridable per control', () {
      final child = FormControl<String>(initialValue: '');
      final parent = _TestGroup(child);
      parent.addListener(() {}); // triggers adoption, so `parent` is set on child

      parent.setValidationMode(ValidationMode.onUnfocus);
      expect(child.validationMode, ValidationMode.onUnfocus); // inherited

      child.setValidationMode(ValidationMode.onUserInteraction);
      expect(child.validationMode, ValidationMode.onUserInteraction); // overridden
      expect(parent.validationMode, ValidationMode.onUnfocus); // parent unaffected
    });

    group('manual (default)', () {
      test('editing does not reveal the error; validate() does', () async {
        final control = FormControl<String>(
          initialValue: '',
          validators: [Validators.required],
        );

        control.value = 'a';
        control.value = ''; // invalid again
        expect(control.touched, isFalse);
        expect(control.displayError, isNull);

        await control.validate();
        expect(control.displayError, 'Required field');
      });

      test('editing after validate() hides the error again', () async {
        final control = FormControl<String>(
          initialValue: '',
          validators: [Validators.required],
        );

        await control.validate();
        expect(control.displayError, isNotNull);

        control.value = 'still invalid but edited';
        control.value = '';
        expect(control.displayError, isNull);
      });
    });

    group('onUserInteraction', () {
      test('every edit reveals the field immediately', () {
        final control = FormControl<String>(
          initialValue: '',
          validators: [Validators.required],
        )..setValidationMode(ValidationMode.onUserInteraction);

        control.value = 'a';
        control.value = '';
        expect(control.displayError, 'Required field');
      });

      test('the async check is debounced, not run on every keystroke', () async {
        var calls = 0;
        final control = FormControl<String>(
          initialValue: '',
          asyncValidators: [
            (value) async {
              calls++;
              return null;
            },
          ],
          asyncValidationDebounce: const Duration(milliseconds: 20),
        )..setValidationMode(ValidationMode.onUserInteraction);

        calls = 0; // ignore the construction-time run
        control.value = 'a';
        control.value = 'ab';
        control.value = 'abc';

        await Future<void>.delayed(const Duration(milliseconds: 5));
        expect(calls, 0); // still within the debounce window

        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(calls, 1); // only the last edit actually ran a check
      });
    });

    group('onUnfocus', () {
      test('editing stays quiet; unfocusing after an edit reveals it', () {
        final control = FormControl<String>(
          initialValue: '',
          validators: [Validators.required],
        )..setValidationMode(ValidationMode.onUnfocus);

        control.value = 'a'; // edited
        control.value = ''; // edited again, still invalid, but no reveal yet
        expect(control.displayError, isNull);

        control.handleUnfocus();
        expect(control.displayError, 'Required field');
      });

      test('unfocusing without an edit costs nothing', () {
        final control = FormControl<String>(initialValue: '')
          ..setValidationMode(ValidationMode.onUnfocus);

        control.handleUnfocus();
        expect(control.touched, isFalse);
      });

      test('editing again after a reveal hides it until the next unfocus', () {
        final control = FormControl<String>(
          initialValue: '',
          validators: [Validators.required],
        )..setValidationMode(ValidationMode.onUnfocus);

        control.value = 'a';
        control.handleUnfocus();
        expect(control.touched, isTrue);

        control.value = '';
        expect(control.displayError, isNull);

        control.handleUnfocus();
        expect(control.displayError, 'Required field');
      });

      test('runs the async check only on unfocus-after-edit, not on every edit', () async {
        var calls = 0;
        final control = FormControl<String>(
          initialValue: '',
          asyncValidators: [
            (value) async {
              calls++;
              return null;
            },
          ],
        )..setValidationMode(ValidationMode.onUnfocus);

        calls = 0; // ignore the construction-time run
        control.value = 'a';
        control.value = 'ab';
        await Future<void>.delayed(Duration.zero);
        expect(calls, 0);

        control.handleUnfocus();
        await Future<void>.delayed(Duration.zero);
        expect(calls, 1);
      });
    });

    group('afterFirstUnfocus', () {
      test('stays quiet while typing, like onUnfocus, before the first check', () {
        final control = FormControl<String>(
          initialValue: '',
          validators: [Validators.required],
        )..setValidationMode(ValidationMode.afterFirstUnfocus);

        control.value = 'a';
        control.value = '';
        expect(control.displayError, isNull);
      });

      test('after the first unfocus-with-edit, every edit reveals immediately', () {
        final control = FormControl<String>(
          initialValue: '',
          validators: [Validators.required],
        )..setValidationMode(ValidationMode.afterFirstUnfocus);

        control.value = 'a';
        control.handleUnfocus(); // first check: graduates to live
        control.value = 'ab';
        expect(control.displayError, isNull); // valid, shown live

        control.value = '';
        expect(control.displayError, 'Required field'); // reveals without another unfocus
      });
    });
  });
}

class _TestGroup extends FormGroup<String, _TestGroup> {
  _TestGroup(this.child);

  final FormControl<String> child;

  @override
  Iterable<FormNode<Object?>> get children => [child];

  @override
  String toValue() => child.value;
}
