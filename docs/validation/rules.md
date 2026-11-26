# Rules

`Validators` ships the common ones, ready to drop into a control's
`validators` list:

| Validator | Applies to | Fails when |
| --- | --- | --- |
| `Validators.required` | any value | `null`, or an empty/blank `String` |
| `Validators.minLength(n)` | `String` | shorter than `n` characters |
| `Validators.maxLength(n)` | `String` | longer than `n` characters |
| `Validators.exactLength(n)` | `String` | not exactly `n` characters |
| `Validators.min(n)` | `num` | less than `n` |
| `Validators.max(n)` | `num` | greater than `n` |
| `Validators.email` | `String` | doesn't look like an email address |
| `Validators.pattern(regExp, {message})` | `String` | doesn't match `regExp` |

```dart
final email = FormControl<String>(
  initialValue: '',
  validators: [Validators.required, Validators.email],
);

final zip = FormControl<String>(
  initialValue: '',
  validators: [Validators.exactLength(8)],
);
```

Each one returns a `ValidationError(message, code: ...)` — read
`error.code` if you ever need to branch on *which* rule failed rather
than just displaying `error.message`.

## Custom validation

A validator is just a function: `ValidationError? Function(T value)` —
return `null` when the value is fine, a `ValidationError` otherwise.
`Validators.custom` is only there so it reads consistently with the
built-in ones at the call site:

```dart
final age = FormControl<int>(
  initialValue: 0,
  validators: [
    Validators.custom((value) {
      if (value < 18) return const ValidationError('Must be 18 or older', code: 'minAge');
      return null;
    }),
  ],
);
```

Since it's a plain function, it can close over anything else it needs
— a regular expression built once outside the control, a value from
another field (for a rule that only depends on *this* control, not a
cross-field one — see [Cross-field
validation](../guides/cross-field-validation.md) for rules spanning a
whole group), or a reference used to surface a server-side error (see
[Server errors](../guides/server-errors.md)).

An async check — one that needs to ask an API, say — goes in
`asyncValidators` instead, as an `AsyncValidator<T>`
(`Future<ValidationError?> Function(T value)`); see [How it
works](how-it-works.md) for when those actually run.
