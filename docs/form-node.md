# FormNode

`FormNode<T>` is the base every `FormControl<T>`, `FormGroup<T, TRoot>`
and `FormArray<T, C>` shares. Every node exposes:

* **`value`** — its current typed value (a single value for a control,
  the built model for a group/array).
* **`valid`/`invalid`**, **`errors`** — `errors` already includes every
  descendant's errors (a group's or array's own, flattened together
  with its children's).
* **`dirty`/`pristine`** — has the value changed since `initialValue`
  (or the last `markAsInitial()`)?
* **`touched`/`untouched`** — has the user interacted with it (or a
  descendant)?
* **`enabled`/`disabled`**.
* **`reset()`** — back to the initial value, recursively.
* It's a `Listenable` (`ChangeNotifier`) — listen to the root form and
  rebuild your widgets when anything in the tree changes.

Two more specific ways to read errors:

* **`displayError`** — a node's own first error (`ownErrors`, not a
  descendant's), but only once it's `touched`; otherwise `null`. The
  "show one message after the user interacts" convention most field
  widgets want, e.g. `TextField(decoration: InputDecoration(errorText: control.displayError))`.
* **`validationErrors`** — every error anywhere in the subtree, as a
  `Map<FormNode<Object?>, List<ValidationError>>` keyed by the node
  that reported it directly, for a form-level error summary that needs
  to know which field each message belongs to.

## Bringing a node into view

`highlight([duration])` sets `isHighlighted` for a bit, then clears it
on its own. Read it in your field's `build` to flash or outline itself
— the library draws nothing by itself. This exists on every `FormNode`,
not just `FormControl` — a group or array can be highlighted too, e.g.
when `validateSelf()` fails and there's no single field to point at.

`FormControl` adds `requestFocus()`/`ensureVisible()` on top of this —
see [Bringing an invalid field into view](invalid-field-attention.md).

## Pre-filling from existing data

There's no `fromValue`/`patchValue`: a `FormGroup` is a plain Dart
class, so a plain function that sets each control's `value` already
works, and already notifies. The one thing the library does for you:
after loading, call `markAsInitial()` — also a `FormNode` method — so
`reset()` goes back to what you just loaded instead of the form's
original, empty state. It rebases every descendant's `initialValue` to
its current value and clears `dirty`, recursively:

```dart
void applyArena(ArenaForm form, Arena arena) {
  form.name.value = arena.name;
  form.international.value = arena.international;
  for (final contact in arena.contacts) {
    form.contacts.add();
    form.contacts.last.name.value = contact.name;
    form.contacts.last.email.value = contact.email;
  }
}

applyArena(form, existingArena);
form.markAsInitial();

form.name.value = 'something else';
form.reset(); // back to existingArena.name, not ''
```
