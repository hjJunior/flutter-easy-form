# Cross-field validation, including against the root form

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
