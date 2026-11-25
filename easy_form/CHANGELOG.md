## [0.1.0-beta.1]

Complete rewrite around a typed, class-based form tree. This is a
breaking change: the previous `EasyForm`/`EasyFormField` API (backed by
`Map<String, dynamic>` and `BuildContext` lookups) is removed.

- `FormNode<T>`: shared contract for value, `dirty`/`touched`,
  `enabled`/`disabled`, validation, reset, and change propagation up
  the tree (built on `ChangeNotifier`).
- `FormControl<T>`: a single typed value, with nullability of `T`
  respected by the type system (no unsafe casts).
- `FormGroup<T, TRoot>`: a typed object composed of other nodes,
  declared by subclassing and exposing real Dart properties — never a
  map. Supports cross-field validation by overriding `validateSelf()`,
  which returns every violation found (so a group can report more than
  one at once), including rules that reach the root form through
  `FormContext<TRoot>` (`context.root`), with no casts.
- `FormArray<T, C>`: an ordered, dynamic collection of controls or
  groups (`add`/`insert`/`removeAt`/`move`/`setAt`), with its own validators.
- `FormNode.markAsInitial()`: rebases `reset()` to the node's (and every
  descendant's) current value, for after loading an existing model by
  hand — there's no `fromValue`/`patchValue` in this library, since a
  plain function setting each control's `value` already works.
- Ready-made validators: `required`, `minLength`, `maxLength`, `min`,
  `max`, `email`, `pattern`, `custom`.
- `FormControlWidget<T>`: base class for a field with no extra resource
  to manage — handles listening to its control and rebuilding, including
  switching listeners if given a different control later.
- `FormControlTextSync<T>`: mixin for a field's own `State` when it needs
  a `TextEditingController` (most commonly a `TextField`). Not a
  replacement for `TextField` itself — you keep writing and customizing
  that widget (masks via `inputFormatters` included); the mixin only
  removes the controller plumbing around it.
- No ready-made field widgets yet (no `TextFormControl`-the-widget, no
  array builders) — see the two helpers above and `example/lib/main.dart`.

## [0.0.1-rc] - Initial Release

- Extensible and easy API to create new fields
- Dynamic field value control from any child
- Initial values and reset form option
- Live update: Rebuild your widgets in realtime when any change happens
- Extensible API to create reusable async and sync validations rule for field
- Dynamic error setter
- Easy access to any field from any child
