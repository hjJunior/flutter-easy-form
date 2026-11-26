# How to structure your project

A suggested layout for where forms, rules and fields each live, as a
project grows past one or two forms:

```
lib/
  forms/
    address/
      address_form.dart       # AddressForm (FormGroup) + Address (model)
    arena/
      arena_form.dart         # ArenaForm — the root FormGroup
      court_form.dart         # CourtForm — nested, a field of ArenaForm
  validators/
    tax_id_validators.dart    # rules shared by more than one form
  widgets/
    inputs/
      app_text_input.dart     # AppTextInput — built once, reused everywhere
      app_date_input.dart
      app_switch_input.dart
```

* **`forms/<feature>/`** — one folder per form, one file per
  `FormGroup` subclass inside it, named after the class
  (`address_form.dart` for `AddressForm`). A form with nested groups
  (see below) keeps every one of its groups in the same folder — they
  aren't reusable outside that form, so there's no reason to scatter
  them. The plain model a form builds (`Address`) can live in the same
  file, or wherever your domain models already live — it has no
  dependency on the form at all, so either works.
* **`validators/`** — a rule shared across more than one form (a
  company's tax-ID format, say) is just a plain function, so it
  belongs here, grouped by what it validates rather than by which form
  uses it. A rule used by exactly one field stays inline instead, in
  that field's own `validators: [...]`, rather than round-tripping
  through this folder for something nothing else needs.
* **`widgets/inputs/`** — the small, reusable input-widget kit
  (`AppTextInput`, `AppDateInput`, `AppSwitchInput`, ...) covered in
  [Using Flutter widgets](../integrate-your-stack/flutter-widgets.md).
  Built once; every form under `forms/` just imports and instantiates
  these, never redefines its own.

Own the form instance in a `State`, not in a widget's `build` — it
must be created once and disposed:

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
form at the actual root of the tree uses itself. `arena_form.dart`
holds both classes, since `CourtForm` only ever makes sense as part of
an `ArenaForm`. See [Cross-field
validation](cross-field-validation.md) for more on `validateSelf()` and
`context.root`.
