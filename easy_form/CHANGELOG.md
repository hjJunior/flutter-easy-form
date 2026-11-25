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
  map. Supports cross-field validation via `validateSelf()` and
  `FormValidationException`, including rules that reach the root form
  through `FormContext<TRoot>` (`context.root`), with no casts.
- `FormArray<T, C>`: an ordered, dynamic collection of controls or
  groups (`add`/`insert`/`removeAt`/`move`), with its own validators.
- Ready-made validators: `required`, `minLength`, `maxLength`, `min`,
  `max`, `email`, `pattern`, `custom`.
- No Flutter field widgets yet (e.g. `TextFormControl`) — the example
  app wires `TextEditingController` to `FormControl` by hand in the
  meantime; dedicated widgets are planned for a later release.

## [0.0.1-rc] - Initial Release

- Extensible and easy API to create new fields
- Dynamic field value control from any child
- Initial values and reset form option
- Live update: Rebuild your widgets in realtime when any change happens
- Extensible API to create reusable async and sync validations rule for field
- Dynamic error setter
- Easy access to any field from any child
