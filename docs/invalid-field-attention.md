# Bringing an invalid field into view

`validate()` can fail on a field that isn't currently on screen — a
previous step of a multi-step form, say. `validationErrors` already
keys every error by the node that reported it, so you can act on each
one directly; `FormControl` adds three primitives for that:

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
  behave differently). `FormControlTextSync`/`FormControlFocusSync`
  detect this themselves (`Scrollable.maybeOf(context)`) and wire
  `Scrollable.ensureVisible` when there is one; attach your own
  callback instead if you need something else.
* **`highlight([duration])`** (on every `FormNode`, not just
  `FormControl`) — sets `isHighlighted` for a bit, then clears it on
  its own. Read it in your field's `build` to flash or outline itself;
  the library draws nothing by itself.

`requestAttention()` is the three together, for the common case. Both
`FormControlTextSync` and `FormControlFocusSync` (for a field with no
`TextEditingController` — a picker, a dropdown, a button) wire
`requestFocus`/`ensureVisible` automatically; see
[Building field widgets](field-widgets.md) and
`example/lib/main.dart`, where tapping an error in the summary list
jumps to the field that reported it.
