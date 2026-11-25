import 'package:flutter_easy_form/flutter_easy_form.dart';

class Contact {
  const Contact({required this.name, required this.email});

  final String name;
  final String email;
}

class Arena {
  const Arena({required this.name, required this.international, required this.contacts});

  final String name;
  final bool international;
  final List<Contact> contacts;
}

/// Belongs under an [ArenaForm]. Reaches the root through [context] to
/// enforce a rule that depends on a field that isn't its own.
class ContactForm extends FormGroup<Contact, ArenaForm> {
  ContactForm({required super.context});

  final name = FormControl<String>(
    initialValue: '',
    validators: [Validators.required],
  );
  final email = FormControl<String>(
    initialValue: '',
    validators: [Validators.required, Validators.email],
  );

  @override
  Iterable<FormNode<Object?>> get children => [name, email];

  @override
  Contact toValue() => Contact(name: name.value, email: email.value);
}

class ArenaForm extends FormGroup<Arena, ArenaForm> {
  final name = FormControl<String>(
    initialValue: '',
    validators: [Validators.required, Validators.minLength(3)],
  );
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
  List<ValidationError> validateSelf() {
    if (international.value && contacts.length == 0) {
      return [
        const ValidationError(
          'An international arena requires at least one contact',
          code: 'international_arena_requires_contact',
        ),
      ];
    }
    return const [];
  }
}
