# flutter_easy_form

[![CI](https://github.com/hjJunior/flutter-easy-form/actions/workflows/ci.yml/badge.svg)](https://github.com/hjJunior/flutter-easy-form/actions/workflows/ci.yml)

Typed, class-based forms for Flutter. A form is a plain Dart class with
real properties — no `Map<String, dynamic>`, no string keys, no casts —
built from four pieces: `FormControl` (one value), `FormGroup` (a typed
object made of other nodes), `FormArray` (a dynamic list of them), and
validators. Everything is a `Listenable`, so a `ListenableBuilder` on
your form already rebuilds whenever anything in it changes.

```dart
class AddressForm extends FormGroup<Address, AddressForm> {
  final street = FormControl<String>(initialValue: '', validators: [Validators.required]);
  final city = FormControl<String>(initialValue: '', validators: [Validators.required]);

  @override
  Iterable<FormNode<Object?>> get children => [street, city];

  @override
  Address toValue() => Address(street: street.value, city: city.value);
}
```

## Where to next

* **[Getting started](getting-started/installation.md)** — install it,
  build your first form, add your first validation.
* **[Validation](validation/how-it-works.md)** — sync and async
  validators, `ValidationMode`, and the built-in rules.
* **[Integrate your stack](integrate-your-stack/flutter-widgets.md)** —
  bind a control to a real `TextField`, date picker or switch.
* **[Guides](guides/project-structure.md)** — structuring a project,
  editing saved data, multi-step forms, array forms, cross-field rules,
  server errors.
* **[Reference](reference/form-node.md)** — `FormNode`, `FormControl`,
  `FormGroup`, `FormArray`, and the project's status/roadmap.

The package's own `README.md` (what pub.dev shows) stays a shorter
summary; this site is the fuller version, kept as Markdown in the same
[GitHub repository](https://github.com/hjJunior/flutter-easy-form) via
Git Sync.
