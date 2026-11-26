import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormNode.highlight', () {
    test('isHighlighted is true immediately, false after the duration', () async {
      final control = FormControl<String>(initialValue: '');
      expect(control.isHighlighted, isFalse);

      control.highlight(duration: const Duration(milliseconds: 20));
      expect(control.isHighlighted, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(control.isHighlighted, isFalse);
    });

    test('calling it again restarts the timer', () async {
      final control = FormControl<String>(initialValue: '');
      control.highlight(duration: const Duration(milliseconds: 20));

      await Future<void>.delayed(const Duration(milliseconds: 10));
      control.highlight(duration: const Duration(milliseconds: 20)); // restarts

      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(control.isHighlighted, isTrue); // would be false already without the restart

      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(control.isHighlighted, isFalse);
    });

    test('notifies when it starts and when it ends', () async {
      final control = FormControl<String>(initialValue: '');
      var notifications = 0;
      control.addListener(() => notifications++);

      control.highlight(duration: const Duration(milliseconds: 10));
      expect(notifications, 1);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(notifications, 2);
    });

    test('dispose cancels a pending highlight timer without error', () async {
      final control = FormControl<String>(initialValue: '');
      control.highlight(duration: const Duration(seconds: 10));
      control.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
  });

  group('FormControl focus and visibility', () {
    test('requestFocus calls an already-attached callback immediately', () {
      final control = FormControl<String>(initialValue: '');
      var calls = 0;
      control.attachRequestFocusCallback(() => calls++);

      control.requestFocus();
      expect(calls, 1);
    });

    test('requestFocus before anything attaches is honored once something does', () {
      final control = FormControl<String>(initialValue: '');
      control.requestFocus(); // nothing attached yet — not lost

      var calls = 0;
      control.attachRequestFocusCallback(() => calls++);
      expect(calls, 1); // the pending request is honored immediately on attach
    });

    test('attaching with no pending request calls nothing', () {
      final control = FormControl<String>(initialValue: '');
      var calls = 0;
      control.attachRequestFocusCallback(() => calls++);
      expect(calls, 0);
    });

    test('ensureVisible calls the attached callback, or does nothing', () {
      final control = FormControl<String>(initialValue: '');
      control.ensureVisible(); // nothing attached: a no-op, not an error

      var calls = 0;
      control.attachEnsureVisibleCallback(() => calls++);
      control.ensureVisible();
      expect(calls, 1);
    });

    test('requestAttention requests focus, ensures visible, and highlights', () {
      final control = FormControl<String>(initialValue: '');
      var focusCalls = 0;
      var visibleCalls = 0;
      control.attachRequestFocusCallback(() => focusCalls++);
      control.attachEnsureVisibleCallback(() => visibleCalls++);

      control.requestAttention();

      expect(focusCalls, 1);
      expect(visibleCalls, 1);
      expect(control.isHighlighted, isTrue);
    });
  });
}
