# Adding validation

Pass `validators` to any `FormControl`:

```dart
final street = FormControl<String>(initialValue: '', validators: [Validators.required]);
```

Then read `valid`/`invalid` on the control (or the whole form, which
aggregates every descendant), and `displayError` for the one message a
field widget should show — a control's own first error, but only once
the user has actually interacted with it:

```dart
TextField(
  controller: textController,
  decoration: InputDecoration(errorText: control.displayError),
  onChanged: (value) => control.value = value,
);
```

```dart
ElevatedButton(
  onPressed: form.valid ? () => save(form.toValue()) : null,
  child: const Text('Save'),
);
```

This is the smallest working setup — a required field, shown once
touched, gating a submit button. From here:

* [Validation](../validation/how-it-works.md) covers *when* errors are
  revealed and async validators run (`ValidationMode`), and what to
  `await` before you actually trust `valid`.
* [Rules](../validation/rules.md) lists every built-in validator and
  how to write your own.
