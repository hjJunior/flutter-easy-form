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

## Status

This is a `0.1.0-beta` rewrite. Dedicated field widgets (a
`TextFormControl`, array builders, etc.) are not implemented yet — the
example app wires `TextEditingController` to `FormControl` by hand in
the meantime.
