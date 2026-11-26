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
- Ready-made validators: `required`, `minLength`, `maxLength`,
  `exactLength`, `min`, `max`, `email`, `pattern`, `custom`.
- `FormControl.asyncValidators`: for checks that can't complete
  synchronously (e.g. an API call). `FormNode.validating` is true while
  one is in flight, aggregating up through groups and arrays the same
  way `dirty`/`touched` do; a stale result (superseded by a newer run
  before it resolved) is discarded.
- A validator that throws or times out instead of resolving sets
  `FormNode.hasFailedValidation` (also aggregating through the tree),
  meant to drive one form-level banner — not a `ValidationError`, which
  would read as "this value is wrong" rather than "the check couldn't
  run". Previously an uncaught exception here would leave the control
  stuck `validating` forever.
- `FormNode.canSubmit`: `valid && !validating && !hasFailedValidation` —
  the actual submit-button-ready signal; `valid` alone says nothing
  about a check still in flight.
- `FormNode.validate()` is now `Future<void>`: it marks the subtree
  touched and recursively awaits every async validator in it, so
  `await form.validate()` is the guarantee `canSubmit`'s synchronous
  snapshot can't give on its own.
- `FormNode.validationErrors`: every error anywhere in the subtree, as a
  `Map<FormNode<Object?>, List<ValidationError>>` keyed by the node that
  reported it directly — unlike `errors`, which already flattens a
  group's or array's descendants into its own list.
- `FormNode.displayError`: a node's own first error, once it's
  `touched` — otherwise `null`. The "show one message after the user
  interacts" convention most field widgets want.
- `FormGroup.toValue()` is formally documented as best-effort: it never
  checks `valid` and never throws, so an invalid or incomplete form
  still builds *a* model.
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
- The example app and the widget tests use `package:material_ui/material_ui.dart`
  instead of the now-deprecated `package:flutter/material.dart` (the
  library itself depends on neither — `FormControlWidget` and
  `FormControlTextSync` only need `package:flutter/widgets.dart`).

## [0.0.1-rc] - Initial Release

- Extensible and easy API to create new fields
- Dynamic field value control from any child
- Initial values and reset form option
- Live update: Rebuild your widgets in realtime when any change happens
- Extensible API to create reusable async and sync validations rule for field
- Dynamic error setter
- Easy access to any field from any child
