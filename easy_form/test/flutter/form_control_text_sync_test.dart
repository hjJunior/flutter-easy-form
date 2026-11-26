import 'package:material_ui/material_ui.dart';
import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';

class _Field extends StatefulWidget {
  const _Field({required this.control});

  final FormControl<String> control;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> with FormControlTextSync<_Field> {
  @override
  FormControl<String> get control => widget.control;

  @override
  Widget build(BuildContext context) => TextField(
        controller: textController,
        onChanged: (value) => control.value = value,
      );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('FormControlTextSync', () {
    testWidgets('seeds the controller with the control\'s initial value', (tester) async {
      final control = FormControl<String>(initialValue: 'Maria');
      await tester.pumpWidget(_wrap(_Field(control: control)));

      expect(find.text('Maria'), findsOneWidget);
    });

    testWidgets('typing through the controller updates the control', (tester) async {
      final control = FormControl<String>(initialValue: '');
      await tester.pumpWidget(_wrap(_Field(control: control)));

      await tester.enterText(find.byType(TextField), 'hello');
      expect(control.value, 'hello');
    });

    testWidgets('an external value change updates the controller\'s text', (tester) async {
      final control = FormControl<String>(initialValue: '');
      await tester.pumpWidget(_wrap(_Field(control: control)));

      control.value = 'set from outside';
      await tester.pump();

      expect(find.text('set from outside'), findsOneWidget);
    });

    testWidgets('switches to a different control and stops listening to the old one',
        (tester) async {
      final first = FormControl<String>(initialValue: 'first');
      final second = FormControl<String>(initialValue: 'second');

      await tester.pumpWidget(_wrap(_Field(control: first)));
      expect(find.text('first'), findsOneWidget);

      await tester.pumpWidget(_wrap(_Field(control: second)));
      expect(find.text('second'), findsOneWidget);

      first.value = 'changed';
      await tester.pump();
      expect(find.text('changed'), findsNothing);
    });

    testWidgets('disposes the controller and the listener without error', (tester) async {
      final control = FormControl<String>(initialValue: '');
      await tester.pumpWidget(_wrap(_Field(control: control)));

      await tester.pumpWidget(_wrap(const SizedBox()));
      control.value = 'still alive'; // must not touch a disposed controller

      expect(tester.takeException(), isNull);
    });
  });
}
