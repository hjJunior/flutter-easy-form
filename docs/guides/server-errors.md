# Server errors

There's no built-in "server error" concept — a validator is just a
function, so a field-specific server error is a validator that reads
from a value your own code sets, scoped to the exact value the server
rejected so it clears itself the moment the user changes it:

```dart
class LoginForm extends FormGroup<Credentials, LoginForm> {
  Object? _emailServerErrorFor;
  ValidationError? _emailServerError;

  final email = FormControl<String>(
    initialValue: '',
    validators: [
      Validators.required,
      Validators.email,
      (value) => value == _emailServerErrorFor ? _emailServerError : null,
    ],
  );

  final password = FormControl<String>(initialValue: '', validators: [Validators.required]);

  @override
  Iterable<FormNode<Object?>> get children => [email, password];

  @override
  Credentials toValue() => Credentials(email: email.value, password: password.value);

  /// Call after a failed request reports this field as the problem.
  void setEmailServerError(String message) {
    _emailServerErrorFor = email.value;
    _emailServerError = ValidationError(message, code: 'server');
    email.markAsTouched();
  }
}
```

```dart
try {
  await api.login(form.toValue());
} on ApiFieldError catch (e) {
  if (e.field == 'email') form.setEmailServerError(e.message);
}
```

Why this shape, and not just setting a field and calling it done:

* The validator compares the control's **current** value against the
  value that was actually rejected (`_emailServerErrorFor`), not just
  whether an error is "set" — so the moment the user edits the field to
  anything else, the validator naturally stops returning it. No
  separate "clear on next edit" wiring needed, and no risk of a stale
  server error surviving a fix.
* `markAsTouched()` reveals it right away via `displayError`,
  regardless of `validationMode` — the same thing `validate()` already
  does to reveal everything on submit.
* Submitting the exact same (still-wrong) value again keeps showing it,
  since the comparison still matches.

The same pattern extends to a form-level error that isn't about one
field (wrong password entirely, account locked, ...) by overriding
`validateSelf()` the same way — compare against a snapshot of
`toValue()` taken when the error arrived, instead of one field's value,
and clear it once any field changes. See [Cross-field
validation](cross-field-validation.md) for `validateSelf()` itself.
