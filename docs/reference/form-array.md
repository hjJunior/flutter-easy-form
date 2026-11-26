# FormArray

`FormArray<T, C>` is an ordered, dynamic collection of controls or
groups — `T` is the item's model type, `C` the node type that builds it
(a `FormControl<T>` or a `FormGroup<T, ...>`).

* **`add()`**, **`insert(index)`**, **`removeAt(index)`**,
  **`move(from, to)`**, **`setAt(index, item)`** — see [Array
  forms](../guides/array-forms.md) for a simple-value list and an
  object list side by side, and `FormArray`'s own `validators` for
  rules about the collection as a whole (e.g. "at least one item").
* **`length`**, `array[index]` — read access, same as a `List`.

Like any node, `valid`, `errors`, `dirty`, `touched` and `reset()`
aggregate across every item — see [`FormNode`](form-node.md) for what's
shared across the whole tree.
