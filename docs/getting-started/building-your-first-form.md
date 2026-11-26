# Building your first form

Start from the plain Dart model you want to produce:

```dart
class Address {
  const Address({required this.street, required this.city});
  final String street;
  final String city;
}
```

Declare your form by subclassing `FormGroup<T, TRoot>` — `T` is the
model it builds, `TRoot` is itself (see [How to structure your
project](../guides/project-structure.md) for what `TRoot` is for once a
form has nested groups):

```dart
class AddressForm extends FormGroup<Address, AddressForm> {
  final street = FormControl<String>(initialValue: '');
  final city = FormControl<String>(initialValue: '');

  @override
  Iterable<FormNode<Object?>> get children => [street, city];

  @override
  Address toValue() => Address(street: street.value, city: city.value);
}
```

* **`children`** — every direct field, so the library knows what to
  aggregate (validity, dirty, touched, reset) and what to notify for.
* **`toValue()`** — builds the model from the current field values.

Now wire a field to a real widget. `FormControlTextSync` is the mixin
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
      onChanged: (value) => control.value = value,
    );
  }
}
```

Create the form once (e.g. as a field on a `State`, disposed in
`dispose()`), and rebuild whenever it changes with a
`ListenableBuilder`:

```dart
final form = AddressForm();

ListenableBuilder(
  listenable: form,
  builder: (context, _) => Column(
    children: [
      StreetField(control: form.street),
      // ... city, following the same pattern
      ElevatedButton(
        onPressed: form.valid ? () => save(form.toValue()) : null,
        child: const Text('Save'),
      ),
    ],
  ),
);
```

That's the whole loop: type a model, declare a form for it, bind each
control to a widget, read `toValue()` once `valid` is true. Next: [adding
validation](adding-validation.md).
