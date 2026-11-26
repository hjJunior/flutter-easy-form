import 'package:material_ui/material_ui.dart';
import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterField extends FormControlWidget<int> {
  const _CounterField({required super.control});

  @override
  Widget build(BuildContext context, FormControl<int> control) {
    return Text('${control.value}');
  }
}

Widget _wrap(Widget child) => Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('FormControlWidget', () {
    testWidgets('renders the control\'s current value', (tester) async {
      final control = FormControl<int>(initialValue: 0);
      await tester.pumpWidget(_wrap(_CounterField(control: control)));

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('rebuilds when the control notifies', (tester) async {
      final control = FormControl<int>(initialValue: 0);
      await tester.pumpWidget(_wrap(_CounterField(control: control)));

      control.value = 1;
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('stops listening to the control once disposed', (tester) async {
      final control = FormControl<int>(initialValue: 0);
      await tester.pumpWidget(_wrap(_CounterField(control: control)));

      await tester.pumpWidget(_wrap(const SizedBox()));
      control.value = 1; // must not call setState on a disposed State

      expect(tester.takeException(), isNull);
    });

    testWidgets('switches listeners when given a different control', (tester) async {
      final first = FormControl<int>(initialValue: 0);
      final second = FormControl<int>(initialValue: 10);

      await tester.pumpWidget(_wrap(_CounterField(control: first)));
      expect(find.text('0'), findsOneWidget);

      await tester.pumpWidget(_wrap(_CounterField(control: second)));
      expect(find.text('10'), findsOneWidget);

      first.value = 99; // no longer listened to
      await tester.pump();
      expect(find.text('99'), findsNothing);

      second.value = 20;
      await tester.pump();
      expect(find.text('20'), findsOneWidget);
    });
  });
}
