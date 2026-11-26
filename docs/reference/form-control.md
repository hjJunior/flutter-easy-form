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

* **`validators`** / **`asyncValidators`** — see
  [Validation](../validation/how-it-works.md) for how they run and
  [Rules](../validation/rules.md) for the built-in ones plus writing
  your own.
* **`validating`**, **`hasFailedValidation`**, **`canSubmit`** — the
  async-aware status flags, covered in
  [Validation](../validation/how-it-works.md).

## Bringing an invalid field into view

`validate()` can fail on a field that isn't currently on screen — a
previous step of a multi-step form, say. `validationErrors` already
keys every error by the node that reported it, so you can act on each
one directly:

```dart
await form.validate();
final invalid = form.validationErrors.keys;
if (invalid.isNotEmpty) {
  final node = invalid.first;
  if (node is FormControl) node.requestAttention();
}
```

* **`requestFocus()`** — focuses the field. If none is attached right
  now (the field isn't mounted — a different step), the request is
  kept and honored the moment one is, e.g. once you navigate there.
* **`ensureVisible()`** — scrolls the field into view if it turns out
  to have a scrollable ancestor; a no-op otherwise, rather than forcing
  one true way to scroll (slivers, a bare `Column`, a `PageView`, ... all
  behave differently).
* **`requestAttention()`** — the three (`requestFocus`, `ensureVisible`,
  and `highlight` from [`FormNode`](form-node.md)) together, for the
  common case.

`FormControlTextSync` and `FormControlFocusSync` (see [Using Flutter
widgets](../integrate-your-stack/flutter-widgets.md)) wire
`requestFocus`/`ensureVisible` automatically, detecting a scrollable
ancestor themselves (`Scrollable.maybeOf(context)`); attach your own
callback instead (`attachRequestFocusCallback`/
`attachEnsureVisibleCallback`) if you need something else. See [Multi-step
forms](../guides/multi-step-forms.md) for the scenario all of this
exists for.
