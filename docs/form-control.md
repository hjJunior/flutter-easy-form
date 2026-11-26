# FormControl

`FormControl<T>` is a single typed value — a leaf in the tree.
`FormControl<String>(initialValue: '')` requires an `initialValue`
because `String` can't be null; `FormControl<String?>()` doesn't.

```dart
final city = FormControl<String>(initialValue: '', validators: [Validators.required]);

city.value = 'São Paulo';
print(city.valid); // true
```

Besides everything every [`FormNode`](form-node.md) has (value,
valid/errors, dirty/touched, reset), `FormControl` adds:

* **`validators`** / **`asyncValidators`** — see [Validation](validation.md)
  for how they run and `ValidationMode` for *when*.
* **`validating`**, **`hasFailedValidation`**, **`canSubmit`** — the
  async-aware status flags, also covered in [Validation](validation.md).
* **`requestFocus()`**, **`ensureVisible()`**, **`requestAttention()`**
  — bringing an off-screen invalid field into view; see [Bringing an
  invalid field into view](invalid-field-attention.md).

`Validators` ships `required`, `minLength`, `maxLength`, `exactLength`,
`min`, `max`, `email`, `pattern` and `custom`.

To bind a control to an actual widget (a `TextField`, a switch, a
picker, ...) without reimplementing any of Flutter's own widgets, see
[Building field widgets](field-widgets.md).
