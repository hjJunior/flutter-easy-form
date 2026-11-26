# Array forms

`FormArray<T, C>` is an ordered, dynamic collection — `T` is the value
produced per item, `C` is the node type held, which can be a plain
`FormControl` (a list of simple values) or a `FormGroup` subclass (a
list of objects).

## Simple list

A list of plain values — tags, say — uses a `FormControl<T>` as `C`:

```dart
final tags = FormArray<String, FormControl<String>>(
  create: () => FormControl<String>(initialValue: ''),
);

tags.add();
tags[0].value = 'flutter';
tags.add();
tags[1].value = 'forms';

print(tags.value); // ['flutter', 'forms']
```

## Object list

A list of objects uses a `FormGroup` subclass as `C`, so each item gets
its own validation, its own nested fields, everything a top-level form
has:

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

## Operations

* **`add()`** — appends a new item, built via `create`.
* **`insert(index)`**, **`removeAt(index)`**, **`move(from, to)`** — the
  usual list operations.
* **`setAt(index, item)`** — swaps in a different node outright, e.g.
  one already built elsewhere with its own values, rather than
  `create`'s defaults.
* **`length`**, `array[index]` — read access, same as a `List`.

Like any node, `valid`, `errors`, `dirty`, `touched` and `reset()`
aggregate across every item — see [`FormNode`](../reference/form-node.md)
for what's shared across the whole tree.

## Validating the list itself

`FormArray` takes its own `validators: List<Validator<List<T>>>`, for a
rule about the collection as a whole rather than any one item — "at
least one contact", say:

```dart
final contacts = FormArray<Contact, ContactForm>(
  create: ContactForm.new,
  validators: [
    Validators.custom((items) {
      if (items.isEmpty) return const ValidationError('Add at least one contact', code: 'minItems');
      return null;
    }),
  ],
);
```

This is separate from each item's own validators — a `ContactForm`
with an empty `name` still fails on its own `Validators.required`,
independent of whether the array itself has enough items.
