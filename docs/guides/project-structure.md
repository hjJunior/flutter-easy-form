# How to structure your project

A few conventions that keep a typed form tree easy to navigate as it
grows, all of them already used in `example/lib`:

* **One file per `FormGroup` subclass**, named after it —
  `address_form.dart` for `AddressForm`. The plain model it builds
  (`Address`) can live in the same file or wherever your domain models
  already live; it has no dependency on the form at all.
* **One file per field widget**, reusable across forms —
  `name_field.dart` for a `NameField` built with `FormControlTextSync`.
  A field widget only needs a `FormControl<T>`, never the form that
  owns it, so the same `NameField` works in any form with a
  `FormControl<String>` to bind it to.
* **Own the form instance in a `State`**, not in a widget's `build` —
  it must be created once and disposed:

  ```dart
  class _AddressScreenState extends State<AddressScreen> {
    final form = AddressForm();

    @override
    void dispose() {
      form.dispose();
      super.dispose();
    }
  }
  ```

## Nested forms

A `FormGroup<T, TRoot>` that's a field of another group passes `TRoot`
through — the type of the ultimate root, not of its own direct parent —
so every level of nesting gets typed, cast-free access to the root via
`context`, however deep it is:

```dart
class ArenaForm extends FormGroup<Arena, ArenaForm> {
  final name = FormControl<String>(initialValue: '');
  final isBeachArena = FormControl<bool>(initialValue: false);

  // `context` is an instance member, so a field that needs it (directly,
  // or through a closure like `create` below) can't be a `final` field
  // initializer — Dart forbids referencing `this` there. Assign it in
  // the constructor body instead, where `context` is already valid.
  late final FormArray<Court, CourtForm> courts;

  ArenaForm() {
    courts = FormArray<Court, CourtForm>(
      create: () => CourtForm(context: context),
    );
  }

  @override
  Iterable<FormNode<Object?>> get children => [name, isBeachArena, courts];

  @override
  Arena toValue() => Arena(
        name: name.value,
        isBeachArena: isBeachArena.value,
        courts: courts.value,
      );
}

class CourtForm extends FormGroup<Court, ArenaForm> {
  CourtForm({required super.context});

  final capacity = FormControl<int>(initialValue: 0);

  @override
  Iterable<FormNode<Object?>> get children => [capacity];

  @override
  Court toValue() => Court(capacity: capacity.value);

  @override
  List<ValidationError> validateSelf() {
    if (context.root.isBeachArena.value && capacity.value > 20) {
      return [const ValidationError('Beach courts hold at most 20 people', code: 'invalid_capacity')];
    }
    return const [];
  }
}
```

`CourtForm`'s own `TRoot` is `ArenaForm`, not `CourtForm` — only the
form at the actual root of the tree uses itself. See [Cross-field
validation](cross-field-validation.md) for more on `validateSelf()` and
`context.root`.

## Where validators live

A rule used by exactly one field stays inline, in that field's
`validators: [...]`. A rule shared across forms (a company's tax-ID
format, say) is just a plain function, so it belongs wherever your
other shared utilities do — e.g. a `validators.dart` next to your
domain models — and gets passed the same way: `validators:
[requiredTaxId]`.
