# flutter_easy_form

[![CI](https://github.com/hjJunior/flutter-easy-form/actions/workflows/ci.yml/badge.svg)](https://github.com/hjJunior/flutter-easy-form/actions/workflows/ci.yml)

Typed, class-based forms for Flutter. A form is a plain Dart class with
real properties — no `Map<String, dynamic>`, no string keys, no casts —
built from four pieces: `FormControl` (one value), `FormGroup` (a typed
object made of other nodes), `FormArray` (a dynamic list of them), and
validators. Everything is a `Listenable`, so a `ListenableBuilder` on
your form already rebuilds whenever anything in it changes.

## Getting started

Not on pub.dev yet (still `0.1.0-beta`) — add it as a git dependency,
pointing at the package's subdirectory in this repo:

```yaml
dependencies:
  flutter_easy_form:
    git:
      url: https://github.com/hjJunior/flutter-easy-form.git
      ref: v2-beta
      path: easy_form
```

Declare your form by subclassing `FormGroup<T, TRoot>` — `T` is the
plain model it builds, `TRoot` is itself (or whichever ancestor group
is the root, for nested forms):

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
```

Then wire each field to a widget. `FormControlTextSync` is the mixin
for anything backed by a `TextEditingController` (a `TextField`, most
commonly) — it owns the controller and focus node and keeps them in
sync with the control for you:

```dart
class StreetField extends StatefulWidget {
  const StreetField({super.key, required this.control});
  final FormControl<String> control;

  @override
  State<StreetField> createState() => _StreetFieldState();
}

class _StreetFieldState extends State<StreetField> with FormControlTextSync<StreetField> {
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

```dart
final form = AddressForm();

ListenableBuilder(
  listenable: form,
  builder: (context, _) => Column(
    children: [
      StreetField(control: form.street),
      // ...
      ElevatedButton(
        onPressed: form.valid ? () => save(form.toValue()) : null,
        child: const Text('Save'),
      ),
    ],
  ),
);
```

That's the whole loop: type a model, declare a form for it, bind each
control to a widget, read `toValue()` once `valid` is true.

## Digging deeper

* **[FormNode](form-node.md)** — what every node (`FormControl`,
  `FormGroup`, `FormArray`) has in common: value, validity, errors,
  dirty/touched, reset.
* **[FormControl](form-control.md)** — a single typed value.
* **[FormGroup](form-group.md)** — composing nodes into a typed model,
  loading existing data.
* **[FormArray](form-array.md)** — a dynamic, ordered list of controls
  or groups.
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

## Reference

* **[Status & roadmap](status.md)** — what's here, what isn't yet.

The package's own `README.md` (what pub.dev shows) stays a shorter
summary; this site is the fuller version, kept as Markdown in the same
[GitHub repository](https://github.com/hjJunior/flutter-easy-form) via
Git Sync.
