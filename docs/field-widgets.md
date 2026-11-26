# Building field widgets

The library doesn't ship ready-made fields (no `TextFormControl`-the-widget)
— you keep writing (and fully customizing) `TextField`, `SwitchListTile`,
or whatever a third-party package gives you, including masks via
`inputFormatters`. Three small helpers remove the plumbing around that:

* **`FormControlWidget<T>`** — for a field with no extra resource to
  manage (a switch, a checkbox, a slider, ...). Extend it and implement
  `build(context, control)`; it listens to the control and rebuilds for
  you, including switching listeners if it's later given a different one.

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

* **`FormControlTextSync<T>`** — a mixin for a field's own `State` when it
  needs a `TextEditingController` (a `TextField`, most commonly). Implement
  `FormControl<String> get control` (typically `=> widget.control`); the
  mixin creates `textController`, keeps its text matching the control's
  value when it changes from outside (without fighting the user's typing
  or cursor position), switches listeners if the control itself changes,
  and disposes everything — `initState`, `didUpdateWidget` and `dispose`
  are all handled for you. It also owns `focusNode` and calls
  `control.handleUnfocus()` on blur, which the `onUnfocus`/
  `afterFirstUnfocus` validation modes need — pass it along.

  ```dart
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

* **`FormControlFocusSync<T>`** — the same idea as `FormControlTextSync`,
  for a field with no `TextEditingController` (a picker, a dropdown, a
  button). Owns `focusNode` and exposes `isFocused`; wires `handleUnfocus`/
  `requestFocus`/`ensureVisible` the same way — see [Bringing an invalid
  field into view](invalid-field-attention.md) for what those do.

See `example/lib/main.dart` for all three in a real screen.
