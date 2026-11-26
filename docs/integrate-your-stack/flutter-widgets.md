# Using Flutter widgets

The library doesn't ship ready-made fields (no `TextFormControl`-the-widget)
— you build your own, on top of `TextField`, `OutlinedButton`,
`SwitchListTile`, or whatever a third-party package gives you, including
masks via `inputFormatters`. Three small helpers remove the plumbing
around that.

**You build each of these once per app, not once per field.** A field
widget only depends on a `FormControl<T>` — never on the form that owns
it — so `AppTextInput`, once written, binds to *any* `FormControl<String>`
in *any* form. Most apps end up with a handful of these (text, date,
switch, maybe a picker or two), each parameterized with whatever your
design needs beyond the control itself (`label`, `hint`, `keyboardType`,
...), and never touch `FormControlTextSync` again after that — every
new form just instantiates the ones it needs.

## Text input

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
class AppTextInput extends StatefulWidget {
  const AppTextInput({super.key, required this.control, required this.label, this.keyboardType});

  final FormControl<String> control;
  final String label;
  final TextInputType? keyboardType;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> with FormControlTextSync<AppTextInput> {
  @override
  FormControl<String> get control => widget.control;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(labelText: widget.label, errorText: control.displayError),
      enabled: control.enabled,
      onChanged: (value) => control.value = value,
    );
  }
}
```

Used for every `FormControl<String>` in every form from here on:

```dart
AppTextInput(control: form.street, label: 'Street'),
AppTextInput(control: form.city, label: 'City'),
AppTextInput(control: contactForm.email, label: 'Email', keyboardType: TextInputType.emailAddress),
```

## Date input

`FormControlFocusSync` is the same idea, for a field with no
`TextEditingController` — a picker, a dropdown, a button. Owns
`focusNode` and exposes `isFocused`; wires `handleUnfocus`/
`requestFocus`/`ensureVisible` the same way, so whichever interaction
ends the "editing" (here, the dialog closing) just needs to call
`control.handleUnfocus()` itself:

```dart
class AppDateInput extends StatefulWidget {
  const AppDateInput({super.key, required this.control, required this.label});

  final FormControl<DateTime?> control;
  final String label;

  @override
  State<AppDateInput> createState() => _AppDateInputState();
}

class _AppDateInputState extends State<AppDateInput> with FormControlFocusSync<AppDateInput> {
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
      child: Text(control.value?.toString() ?? widget.label),
    );
  }
}
```

## Switch input

For a field with no extra resource to manage at all (a switch, a
checkbox, a slider, ...), `FormControlWidget<T>` skips the `State`
entirely: extend it and implement `build(context, control)`; it
listens to the control and rebuilds for you, including switching
listeners if it's later given a different one.

```dart
class AppSwitchInput extends FormControlWidget<bool> {
  const AppSwitchInput({super.key, required super.control, required this.label});

  final String label;

  @override
  Widget build(BuildContext context, FormControl<bool> control) {
    return SwitchListTile(
      title: Text(label),
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

See `example/lib/main.dart` for all three mixins in a real screen, and
[How to structure your project](../guides/project-structure.md) for
where this small set of input widgets is meant to live.
