import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _PickerField extends StatefulWidget {
  const _PickerField({required this.control});

  final FormControl<String> control;

  @override
  State<_PickerField> createState() => _PickerFieldState();
}

class _PickerFieldState extends State<_PickerField> with FormControlFocusSync<_PickerField> {
  @override
  FormControl<String> get control => widget.control;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      focusNode: focusNode,
      onPressed: () {},
      child: Text(isFocused ? 'focused' : 'unfocused'),
    );
  }
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('FormControlFocusSync', () {
    testWidgets('isFocused reflects focus and rebuilds the field', (tester) async {
      final control = FormControl<String>(initialValue: '');
      await tester.pumpWidget(_wrap(_PickerField(control: control)));
      expect(find.text('unfocused'), findsOneWidget);

      final state = tester.state<_PickerFieldState>(find.byType(_PickerField));
      state.focusNode.requestFocus();
      await tester.pump();

      expect(find.text('focused'), findsOneWidget);
    });

    testWidgets('control.requestFocus() focuses the field', (tester) async {
      final control = FormControl<String>(initialValue: '');
      await tester.pumpWidget(_wrap(_PickerField(control: control)));

      control.requestFocus();
      await tester.pump();

      expect(find.text('focused'), findsOneWidget);
    });

    testWidgets('control.handleUnfocus() fires when the field loses focus', (tester) async {
      final control = FormControl<String>(
        initialValue: '',
        validators: [Validators.required],
      )..setValidationMode(ValidationMode.onUnfocus);

      await tester.pumpWidget(_wrap(
        Column(children: [_PickerField(control: control), const TextField()]),
      ));

      control.requestFocus();
      await tester.pump();
      control.value = 'a'; // edited while focused

      await tester.tap(find.byType(TextField)); // moves focus away
      await tester.pump();

      expect(control.touched, isTrue);
    });

    testWidgets('ensureVisible never throws, with or without a scrollable ancestor',
        (tester) async {
      final control = FormControl<String>(initialValue: '');

      await tester.pumpWidget(_wrap(_PickerField(control: control))); // no scrollable
      control.ensureVisible();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _wrap(SingleChildScrollView(child: _PickerField(control: control))),
      );
      control.ensureVisible();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
