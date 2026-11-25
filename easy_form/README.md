# flutter_easy_form

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
- **`Validators`** — `required`, `minLength`, `maxLength`, `min`,
  `max`, `email`, `pattern`, `custom`.

Every node exposes `value`, `valid`/`invalid`, `errors`, `dirty`/`pristine`,
`touched`/`untouched`, `enabled`/`disabled`, `reset()` and is itself a
`Listenable` (`ChangeNotifier`) — listen to the root form and rebuild your
widgets when anything in the tree changes.

`toValue()` is best-effort: it doesn't check `valid` and never throws, so
an invalid or incomplete form still builds *a* model (a required field
left empty contributes `''`, for instance). Check `valid` yourself first
if the result needs to be correct, not just buildable — see the "Salvar"
button in `example/lib/main.dart`.

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
  are all handled for you.

  ```dart
  class _NameFieldState extends State<NameField> with FormControlTextSync<NameField> {
    @override
    FormControl<String> get control => widget.control;

    @override
    Widget build(BuildContext context) {
      return TextField(
        controller: textController,
        onChanged: (value) => control.value = value,
      );
    }
  }
  ```

See `example/lib/main.dart` for both in a real screen.

## Status

This is a `0.1.0-beta` rewrite. The core is typed end to end; `FormControlWidget`
and `FormControlTextSync` cover the common plumbing for building your own
field widgets, but the library doesn't ship ready-made fields yet (no
`TextFormControl`-the-widget, no array builders).
