# Using Flutter widgets

The library doesn't ship ready-made fields (no `TextFormControl`-the-widget)
— you keep writing (and fully customizing) `TextField`, `OutlinedButton`,
`SwitchListTile`, or whatever a third-party package gives you, including
masks via `inputFormatters`. Three small helpers remove the plumbing
around that; a control binds to exactly one of them depending on what
kind of widget it drives.

## Text field

`FormControlTextSync` is the mixin for a field's own `State` when it
needs a `TextEditingController`. Implement `FormControl<String> get
control` (typically `=> widget.control`); the mixin creates
`textController`, keeps its text matching the control's value when it
changes from outside (without fighting the user's typing or cursor
position), switches listeners if the control itself changes, and
disposes everything — `initState`, `didUpdateWidget` and `dispose` are
all handled for you. It also owns `focusNode` and calls
`control.handleUnfocus()` on blur, which the `onUnfocus`/
`afterFirstUnfocus` validation modes need — pass it along.

```dart
class NameField extends StatefulWidget {
  const NameField({super.key, required this.control});
  final FormControl<String> control;

  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> with FormControlTextSync<NameField> {
  @override
  FormControl<String> get control => widget.control;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      decoration: InputDecoration(errorText: control.displayError),
      onChanged: (value) => control.value = value,
    );
  }
}
```

## Date picker

`FormControlFocusSync` is the same idea, for a field with no
`TextEditingController` — a picker, a dropdown, a button. Owns
`focusNode` and exposes `isFocused`; wires `handleUnfocus`/
`requestFocus`/`ensureVisible` the same way, so whichever interaction
ends the "editing" (here, the dialog closing) just needs to call
`control.handleUnfocus()` itself:

```dart
class DateField extends StatefulWidget {
  const DateField({super.key, required this.control});
  final FormControl<DateTime?> control;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> with FormControlFocusSync<DateField> {
  @override
  FormControl<DateTime?> get control => widget.control;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      focusNode: focusNode,
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: control.value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) control.value = picked;
        control.handleUnfocus(); // the dialog handled its own focus
      },
      style: OutlinedButton.styleFrom(
        side: isFocused ? const BorderSide(width: 2) : null,
      ),
      child: Text(control.value?.toString() ?? 'Pick a date'),
    );
  }
}
```

## Switch

For a field with no extra resource to manage at all (a switch, a
checkbox, a slider, ...), `FormControlWidget<T>` skips the `State`
entirely: extend it and implement `build(context, control)`; it
listens to the control and rebuilds for you, including switching
listeners if it's later given a different one.

```dart
class InternationalSwitch extends FormControlWidget<bool> {
  const InternationalSwitch({super.key, required super.control});

  @override
  Widget build(BuildContext context, FormControl<bool> control) {
    return SwitchListTile(
      value: control.value,
      onChanged: control.disabled ? null : (value) => control.value = value,
    );
  }
}
```

## Bringing a field into view

All three mixins wire `requestFocus`/`ensureVisible` automatically, so
a control created anywhere in the tree can ask its bound widget for
attention without the widget needing to be looked up — see
[`FormControl`](../reference/form-control.md) for `requestFocus()`,
`ensureVisible()`, `highlight()` and `requestAttention()`, and [Multi-step
forms](../guides/multi-step-forms.md) for the scenario they exist for.

See `example/lib/main.dart` for all three mixins in a real screen.
