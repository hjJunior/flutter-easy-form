# Core concepts

## Building blocks

* **`FormControl<T>`** — a single typed value. `FormControl<String>()`
  requires an `initialValue` because `String` can't be null;
  `FormControl<String?>()` doesn't.
* **`FormGroup<T, TRoot>`** — an object composed of other nodes,
  declared by subclassing. `toValue()` builds the typed domain model;
  override `validateSelf()` to validate fields against each other (see
  [Cross-field validation](cross-field-validation.md)).
* **`FormArray<T, C>`** — an ordered, dynamic collection of controls or
  groups: `add()`, `insert(index)`, `removeAt(index)`, `move(from, to)`.
* **`Validators`** — `required`, `minLength`, `maxLength`, `exactLength`,
  `min`, `max`, `email`, `pattern`, `custom`.

Every node exposes `value`, `valid`/`invalid`, `errors`, `dirty`/`pristine`,
`touched`/`untouched`, `enabled`/`disabled`, `reset()` and is itself a
`Listenable` (`ChangeNotifier`) — listen to the root form and rebuild your
widgets when anything in the tree changes.

`errors` already includes every descendant's errors (a `FormGroup`'s or
`FormArray`'s own, flattened together with its children's). Two more
specific ways to read errors:

* **`displayError`** — a node's own first error (`ownErrors`, not a
  descendant's), but only once it's `touched`; otherwise `null`. The
  "show one message after the user interacts" convention most field
  widgets want, e.g. `TextField(decoration: InputDecoration(errorText: control.displayError))`.
* **`validationErrors`** — every error anywhere in the subtree, as a
  `Map<FormNode<Object?>, List<ValidationError>>` keyed by the node
  that reported it directly, for a form-level error summary that needs
  to know which field each message belongs to.

`toValue()` is best-effort: it doesn't check `valid` and never throws, so
an invalid or incomplete form still builds *a* model (a required field
left empty contributes `''`, for instance). Check `valid` yourself first
if the result needs to be correct, not just buildable — see the "Salvar"
button in `example/lib/main.dart`, and [Awaiting validation before you
submit](validation.md#awaiting-validation-before-you-submit) for why
`await form.validate()` is what actually makes `valid` trustworthy when
async validators are involved.

## Dynamic arrays

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

`insert(index)`, `removeAt(index)` and `move(oldIndex, newIndex)` round out the
usual list operations. `setAt(index, item)` swaps in a different node
outright — e.g. one already built elsewhere with its own values, rather
than `create`'s defaults.
