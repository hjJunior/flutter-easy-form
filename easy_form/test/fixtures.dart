import 'package:flutter_easy_form/flutter_easy_form.dart';

/// A standalone root form (`TRoot` is itself), used in tests that exercise
/// generic FormGroup behaviour unrelated to cross-level validation.
class Person {
  const Person({required this.name, required this.email});

  final String name;
  final String email;
}

class PersonForm extends FormGroup<Person, PersonForm> {
  final name = FormControl<String>(
    initialValue: '',
    validators: [Validators.required],
  );
  final email = FormControl<String>(initialValue: '');

  @override
  Iterable<FormNode<Object?>> get children => [name, email];

  @override
  Person toValue() => Person(name: name.value, email: email.value);
}

class Contact {
  const Contact({required this.name, required this.email});

  final String name;
  final String email;

  @override
  String toString() => 'Contact(name: $name, email: $email)';
}

/// Belongs under an [ArenaForm]: reaches the root through [context] to
/// validate a rule that depends on a sibling field (`international`).
class ContactForm extends FormGroup<Contact, ArenaForm> {
  ContactForm({required super.context});

  final name = FormControl<String>(
    initialValue: '',
    validators: [Validators.required],
  );
  final email = FormControl<String>(initialValue: '');

  @override
  Iterable<FormNode<Object?>> get children => [name, email];

  @override
  Contact toValue() => Contact(name: name.value, email: email.value);

  @override
  void validateSelf() {
    if (context.root.international.value && email.value.isEmpty) {
      throw const FormValidationException(
        code: 'email_required_for_international_arena',
        message: 'E-mail é obrigatório para contatos de arenas internacionais',
      );
    }
  }
}

class Arena {
  const Arena({required this.name, required this.international, required this.contacts});

  final String name;
  final bool international;
  final List<Contact> contacts;
}

class ArenaForm extends FormGroup<Arena, ArenaForm> {
  final name = FormControl<String>(initialValue: '');
  final international = FormControl<bool>(initialValue: false);

  // `context` is an instance member: this field is built in the
  // constructor body, not inline, because its closure needs it.
  late final FormArray<Contact, ContactForm> contacts;

  ArenaForm() {
    contacts = FormArray<Contact, ContactForm>(create: () => ContactForm(context: context));
  }

  @override
  Iterable<FormNode<Object?>> get children => [name, international, contacts];

  @override
  Arena toValue() => Arena(
        name: name.value,
        international: international.value,
        contacts: contacts.value,
      );

  @override
  void validateSelf() {
    if (international.value && contacts.length == 0) {
      throw const FormValidationException(
        code: 'international_arena_requires_contact',
        message: 'Arena internacional precisa de ao menos um contato',
      );
    }
  }
}
