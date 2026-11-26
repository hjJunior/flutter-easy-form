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

## Where to next

* **[Core concepts](core-concepts.md)** — `FormControl`, `FormGroup`,
  `FormArray`, and how to read validity and errors.
* **[Loading an existing model](loading-existing-model.md)** — editing a
  form that starts from data you already have.
* **[Validation](validation.md)** — sync and async validators, when
  they run (`ValidationMode`), and what to await before you submit.
* **[Bringing an invalid field into view](invalid-field-attention.md)**
  — focus, scroll-into-view and highlight for a field that failed
  somewhere off-screen (a previous step of a multi-step form, say).
* **[Cross-field validation](cross-field-validation.md)** — rules
  between a group's own fields, including against the root form.
* **[Building field widgets](field-widgets.md)** — the three Flutter
  helpers that remove the plumbing around your own `TextField`,
  `SwitchListTile`, picker, or anything else.
* **[Status & roadmap](status.md)** — what's here, what isn't yet.

The package's own `README.md` (what pub.dev shows) stays a shorter
summary; this site is the fuller version, kept as Markdown in the same
[GitHub repository](https://github.com/hjJunior/flutter-easy-form) via
Git Sync.
