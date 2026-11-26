# flutter_easy_form

[![CI](https://github.com/hjJunior/flutter-easy-form/actions/workflows/ci.yml/badge.svg)](https://github.com/hjJunior/flutter-easy-form/actions/workflows/ci.yml)

Typed, class-based forms for Flutter. Declare a form as a plain Dart
class with real properties — no `Map<String, dynamic>`, no string keys,
no casts.

```dart
class Address {
  const Address({required this.street, required this.city});
  final String street;
  final String city;
}

class AddressForm extends FormGroup<Address, AddressForm> {
  final street = FormControl<String>(initialValue: '', validators: [Validators.required]);
  final city = FormControl<String>(initialValue: '', validators: [Validators.required]);

  @override
  Iterable<FormNode<Object?>> get children => [street, city];

  @override
  Address toValue() => Address(street: street.value, city: city.value);
}

final form = AddressForm();
form.street.value = 'Av. Paulista, 1000';
form.city.value = 'São Paulo';

if (form.valid) {
  final Address address = form.toValue();
}
```

## Building blocks

- **`FormControl<T>`** — a single typed value. `FormControl<String>()`
  requires an `initialValue` because `String` can't be null;
  `FormControl<String?>()` doesn't.
- **`FormGroup<T, TRoot>`** — an object composed of other nodes,
  declared by subclassing. `toValue()` builds the typed domain model;
  override `validateSelf()` to validate fields against each other.
- **`FormArray<T, C>`** — an ordered, dynamic collection of controls or
  groups: `add()`, `insert(index)`, `removeAt(index)`, `move(from, to)`.
- **`Validators`** — `required`, `minLength`, `maxLength`, `exactLength`,
  `min`, `max`, `email`, `pattern`, `custom`.

Every node exposes `value`, `valid`/`invalid`, `errors`, `dirty`/`pristine`,
`touched`/`untouched`, `enabled`/`disabled`, `reset()` and is itself a
`Listenable` (`ChangeNotifier`) — listen to the root form and rebuild your
widgets when anything in the tree changes.

`errors` already includes every descendant's errors (a `FormGroup`'s or
`FormArray`'s own, flattened together with its children's). Two more
specific ways to read errors:

- **`displayError`** — a node's own first error (`ownErrors`, not a
  descendant's), but only once it's `touched`; otherwise `null`. The
  "show one message after the user interacts" convention most field
  widgets want, e.g. `TextField(decoration: InputDecoration(errorText: control.displayError))`.
- **`validationErrors`** — every error anywhere in the subtree, as a
  `Map<FormNode<Object?>, List<ValidationError>>` keyed by the node
  that reported it directly, for a form-level error summary that needs
  to know which field each message belongs to.

`toValue()` is best-effort: it doesn't check `valid` and never throws, so
an invalid or incomplete form still builds *a* model (a required field
left empty contributes `''`, for instance). Check `valid` yourself first
if the result needs to be correct, not just buildable — see the "Salvar"
button in `example/lib/main.dart`, and "Awaiting validation before you
submit" below for why `await form.validate()` is what actually makes
`valid` trustworthy when async validators are involved.

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

## Loading an existing model

There's no `fromValue`/`patchValue` in this library: `FormGroup` is a plain
Dart class, so a plain function that sets each control's `value` already
works, and already notifies:

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
```

The one thing the library does for you: after loading, call
`form.markAsInitial()` so `reset()` goes back to what you just loaded
instead of the form's original, empty state. It rebases every
descendant's `initialValue` to its current value and clears `dirty`,
recursively.

```dart
applyArena(form, existingArena);
form.markAsInitial();

form.name.value = 'something else';
form.reset(); // back to existingArena.name, not ''
```

## Async validators

A check that can't complete synchronously — asking an API whether a
username is taken, say — goes in `asyncValidators` instead of
`validators`:

```dart
final username = FormControl<String>(
  initialValue: '',
  asyncValidators: [
    (value) async {
      final taken = await api.isUsernameTaken(value);
      return taken ? const ValidationError('Already taken', code: 'taken') : null;
    },
  ],
);
```

They always run once on construction and on `reset()`; beyond that,
*when* they run (and when their control reveals its errors at all) is
governed by `validationMode` — see the next section. `validating` is
true while one is in flight (it aggregates up through groups and
arrays, same as `dirty` and `touched`); `errors` only gains the async
result once it resolves — `valid`/`invalid` aren't affected by
`validating` itself, only by what ends up in `errors`. A result that
arrives after a newer run has already started (the value changed
again, or the control reset, before it resolved) is discarded — it no
longer matches the live value.

### When validation runs (`ValidationMode`)

`errors`/`valid` are always computed live from the current value —
that part never waits for anything. What a `ValidationMode` controls is
*when a control is willing to show what it already knows*, and *when
an async validator actually runs* rather than just when it's shown:

| Mode | Editing | Leaving the field (after an edit) |
| --- | --- | --- |
| `manual` (default) | hides whatever error was shown for the old value | — |
| `onUserInteraction` | reveals immediately; the async check waits out `asyncValidationDebounce` | — |
| `onUnfocus` | stays quiet | reveals, and runs the async check |
| `afterFirstUnfocus` | quiet until the first check, then behaves like `onUserInteraction` | reveals, and runs the async check (the first time) |

Nothing reveals on its own until `validate()` (submit) in `manual` mode;
leaving a field unchanged, in any mode, never triggers anything
("tabbing through costs nothing").

Set a form-wide default on the root, and let a single control opt out:

```dart
final form = ArenaForm()..setValidationMode(ValidationMode.onUnfocus);

form.name.setValidationMode(ValidationMode.onUserInteraction);
```

A mode is inherited from the nearest ancestor that set one, defaulting
to `manual` at the root. `onUnfocus` and `afterFirstUnfocus` need to
know when the field loses focus: `FormControlTextSync` wires this for
you automatically (via the `focusNode` it exposes); a custom field that
manages its own focus or interaction (a picker, a dropdown) calls
`control.handleUnfocus()` itself once that interaction ends — a no-op
if the value hasn't actually changed since the last check.

### Awaiting validation before you submit

`valid` is a snapshot: on a quiet form nobody has touched yet, it's
`true` even if an async check would eventually say otherwise. For an
actual guarantee, `await` the tree's `validate()` — it marks everything
touched and, recursively, waits for every async validator anywhere in
it to settle:

```dart
await form.validate();
if (form.canSubmit) {
  final model = form.toValue();
  // ...
}
```

`canSubmit` is the submit-button-ready signal: `valid && !validating &&
!hasFailedValidation`. Checking `valid` alone isn't enough, because it
says nothing about a check still in flight.

### When an async validator itself fails

A validator that throws or times out (wrap it in `.timeout(...)` for
that) doesn't become a `ValidationError` — that would read as "this
value is wrong", when really it's that the check couldn't run.
Instead, it sets `hasFailedValidation` (aggregating through the tree
like `validating` does), meant to drive one form-level banner —
"Some checks couldn't run, try again" — rather than a per-field
message. It also blocks `canSubmit`. The next value change, `reset()`,
or `validate()` call gives the check another chance.

## Bringing an invalid field into view

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

- **`requestFocus()`** — focuses the field. If none is attached right
  now (the field isn't mounted — a different step), the request is
  kept and honored the moment one is, e.g. once you navigate there.
- **`ensureVisible()`** — scrolls the field into view if it turns out
  to have a scrollable ancestor; a no-op otherwise, rather than forcing
  one true way to scroll (slivers, a bare `Column`, a `PageView`, ... all
  behave differently). `FormControlTextSync`/`FormControlFocusSync`
  detect this themselves (`Scrollable.maybeOf(context)`) and wire
  `Scrollable.ensureVisible` when there is one; attach your own
  callback instead if you need something else.
- **`highlight([duration])`** (on every `FormNode`, not just
  `FormControl`) — sets `isHighlighted` for a bit, then clears it on
  its own. Read it in your field's `build` to flash or outline itself;
  the library draws nothing by itself.

`requestAttention()` is the three together, for the common case. Both
`FormControlTextSync` and `FormControlFocusSync` (for a field with no
`TextEditingController` — a picker, a dropdown, a button) wire
`requestFocus`/`ensureVisible` automatically; see
`example/lib/main.dart`, where tapping an error in the summary list
jumps to the field that reported it.

## Cross-field validation, including against the root form

A `FormGroup`'s own fields are validated together by overriding
`validateSelf()`, which returns every violation found (empty when valid —
the same convention `Validator<T>` uses, just able to report more than
one error at once, since a group can fail more than one cross-field
rule in the same pass):

```dart
class ArenaForm extends FormGroup<Arena, ArenaForm> {
  final international = FormControl<bool>(initialValue: false);
  late final FormArray<Contact, ContactForm> contacts;

  ArenaForm() {
    // `context` is an instance member, so a field whose closure needs it
    // (directly, or like here through FormArray's `create`) is assigned
    // in the constructor body — Dart doesn't allow referencing `this` in
    // an inline field initializer.
    contacts = FormArray<Contact, ContactForm>(create: () => ContactForm(context: context));
  }

  @override
  Iterable<FormNode<Object?>> get children => [international, contacts];

  @override
  Arena toValue() => Arena(international: international.value, contacts: contacts.value);

  @override
  List<ValidationError> validateSelf() {
    if (international.value && contacts.length == 0) {
      return [const ValidationError('Needs at least one contact', code: 'international_arena_requires_contact')];
    }
    return const [];
  }
}
```

A nested group reaches the root form the same way, through `context`,
without any cast — `TRoot` is the root form's own type:

```dart
class ContactForm extends FormGroup<Contact, ArenaForm> {
  ContactForm({required super.context});

  final email = FormControl<String>(initialValue: '');

  @override
  Iterable<FormNode<Object?>> get children => [email];

  @override
  Contact toValue() => Contact(email: email.value);

  @override
  List<ValidationError> validateSelf() {
    if (context.root.international.value && email.value.isEmpty) {
      return [const ValidationError('Email is required', code: 'email_required_for_international_arena')];
    }
    return const [];
  }
}
```

See `example/lib/arena_form.dart` and `example/lib/main.dart` for a full,
runnable form with dynamic contacts and this exact rule.

## Building field widgets

The library doesn't ship ready-made fields (no `TextFormControl`-the-widget)
— you keep writing (and fully customizing) `TextField`, `SwitchListTile`,
or whatever a third-party package gives you, including masks via
`inputFormatters`. Two small helpers remove the plumbing around that:

- **`FormControlWidget<T>`** — for a field with no extra resource to
  manage (a switch, a checkbox, a slider, ...). Extend it and implement
  `build(context, control)`; it listens to the control and rebuilds for
  you, including switching listeners if it's later given a different one.

  ```dart
  class InternationalSwitch extends FormControlWidget<bool> {
    const InternationalSwitch({super.key, required super.control});

    @override
    Widget build(BuildContext context, FormControl<bool> control) {
      return SwitchListTile(
        value: control.value,
        onChanged: control.disabled ? null : (value) => control.value = value,
      );
    }
  }
  ```

- **`FormControlTextSync<T>`** — a mixin for a field's own `State` when it
  needs a `TextEditingController` (a `TextField`, most commonly). Implement
  `FormControl<String> get control` (typically `=> widget.control`); the
  mixin creates `textController`, keeps its text matching the control's
  value when it changes from outside (without fighting the user's typing
  or cursor position), switches listeners if the control itself changes,
  and disposes everything — `initState`, `didUpdateWidget` and `dispose`
  are all handled for you. It also owns `focusNode` and calls
  `control.handleUnfocus()` on blur, which the `onUnfocus`/
  `afterFirstUnfocus` validation modes need — pass it along.

  ```dart
  class _NameFieldState extends State<NameField> with FormControlTextSync<NameField> {
    @override
    FormControl<String> get control => widget.control;

    @override
    Widget build(BuildContext context) {
      return TextField(
        controller: textController,
        focusNode: focusNode,
        decoration: InputDecoration(errorText: control.displayError),
        onChanged: (value) => control.value = value,
      );
    }
  }
  ```

- **`FormControlFocusSync<T>`** — the same idea as `FormControlTextSync`,
  for a field with no `TextEditingController` (a picker, a dropdown, a
  button). Owns `focusNode` and exposes `isFocused`; wires `handleUnfocus`/
  `requestFocus`/`ensureVisible` the same way.

See `example/lib/main.dart` for all three in a real screen.

## Status

This is a `0.1.0-beta` rewrite. The core is typed end to end; `FormControlWidget`,
`FormControlTextSync` and `FormControlFocusSync` cover the common plumbing
for building your own field widgets, but the library doesn't ship
ready-made fields yet (no `TextFormControl`-the-widget, no array builders).
