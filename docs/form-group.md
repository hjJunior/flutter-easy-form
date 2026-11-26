# FormGroup

`FormGroup<T, TRoot>` is an object composed of other nodes, declared by
subclassing it — `T` is the plain model it builds, `TRoot` is the root
form's own type (itself, unless it's nested inside another group):

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

* **`children`** — every direct child node; drives how `valid`,
  `errors`, `dirty`, `touched` and `reset()` aggregate.
* **`toValue()`** — builds the typed model. It's best-effort: it
  doesn't check `valid` and never throws, so an invalid or incomplete
  form still builds *a* model (a required field left empty contributes
  `''`, for instance). Check `valid` yourself first if the result needs
  to be correct, not just buildable — see the "Salvar" button in
  `example/lib/main.dart`, and [Awaiting validation before you
  submit](validation.md#awaiting-validation-before-you-submit) for why
  `await form.validate()` is what actually makes `valid` trustworthy
  when async validators are involved.
* **`validateSelf()`** — override to validate the group's own fields
  against each other (and, through `context`, against the root form) —
  see [Cross-field validation](cross-field-validation.md).

For what's inherited from the shared base — `value`, `errors`,
`reset()`, `markAsInitial()`, `highlight()` — see [FormNode](form-node.md),
including how to pre-fill a group from data you already have.
