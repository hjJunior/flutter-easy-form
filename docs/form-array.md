# FormArray

`FormArray<T, C>` is an ordered, dynamic collection of controls or
groups — `T` is the item's model type, `C` the node type that builds it
(a `FormControl<T>` or a `FormGroup<T, ...>`):

```dart
class ContactForm extends FormGroup<Contact, ContactForm> {
  final name = FormControl<String>(initialValue: '', validators: [Validators.required]);

  @override
  Iterable<FormNode<Object?>> get children => [name];

  @override
  Contact toValue() => Contact(name: name.value);
}

final contacts = FormArray<Contact, ContactForm>(create: ContactForm.new);
contacts.add();
contacts[0].name.value = 'Maria';
```

* **`add()`** — appends a new item, built via `create`.
* **`insert(index)`**, **`removeAt(index)`**, **`move(from, to)`** — the
  usual list operations.
* **`setAt(index, item)`** — swaps in a different node outright, e.g.
  one already built elsewhere with its own values, rather than
  `create`'s defaults.
* **`length`**, `[index]` — read access, same as a `List`.

Like any node, `valid`, `errors`, `dirty`, `touched` and `reset()`
aggregate across every item — see [FormNode](form-node.md) for what's
shared across the whole tree.
