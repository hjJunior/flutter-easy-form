# How it works

`errors`/`valid` are always computed live from a control's current
`validators` — that part never waits for anything. A check that can't
complete synchronously — asking an API whether a username is taken,
say — goes in `asyncValidators` instead:

```dart
final username = FormControl<String>(
  initialValue: '',
  asyncValidators: [
    (value) async {
      final taken = await api.isUsernameTaken(value);
      return taken ? const ValidationError('Already taken', code: 'taken') : null;
    },
  ],
);
```

They always run once on construction and on `reset()`; beyond that,
*when* they run (and when their control reveals its errors at all) is
governed by `validationMode` — see the next section. `validating` is
true while one is in flight (it aggregates up through groups and
arrays, same as `dirty` and `touched`); `errors` only gains the async
result once it resolves — `valid`/`invalid` aren't affected by
`validating` itself, only by what ends up in `errors`. A result that
arrives after a newer run has already started (the value changed
again, or the control reset, before it resolved) is discarded — it no
longer matches the live value.

## When validation runs (`ValidationMode`)

What a `ValidationMode` controls is *when a control is willing to show
what it already knows*, and *when an async validator actually runs*
rather than just when it's shown:

| Mode | Editing | Leaving the field (after an edit) |
| --- | --- | --- |
| `manual` (default) | hides whatever error was shown for the old value | — |
| `onUserInteraction` | reveals immediately; the async check waits out `asyncValidationDebounce` | — |
| `onUnfocus` | stays quiet | reveals, and runs the async check |
| `afterFirstUnfocus` | quiet until the first check, then behaves like `onUserInteraction` | reveals, and runs the async check (the first time) |

Nothing reveals on its own until `validate()` (submit) in `manual` mode;
leaving a field unchanged, in any mode, never triggers anything
("tabbing through costs nothing").

Set a form-wide default on the root, and let a single control opt out:

```dart
final form = ArenaForm()..setValidationMode(ValidationMode.onUnfocus);

form.name.setValidationMode(ValidationMode.onUserInteraction);
```

A mode is inherited from the nearest ancestor that set one, defaulting
to `manual` at the root. `onUnfocus` and `afterFirstUnfocus` need to
know when the field loses focus: `FormControlTextSync` and
`FormControlFocusSync` wire this for you automatically (via the
`focusNode` they expose); a custom field that manages its own focus or
interaction calls `control.handleUnfocus()` itself once that
interaction ends — a no-op if the value hasn't actually changed since
the last check.

## Awaiting validation before you submit

`valid` is a snapshot: on a quiet form nobody has touched yet, it's
`true` even if an async check would eventually say otherwise. For an
actual guarantee, `await` the tree's `validate()` — it marks everything
touched and, recursively, waits for every async validator anywhere in
it to settle:

```dart
await form.validate();
if (form.canSubmit) {
  final model = form.toValue();
  // ...
}
```

`canSubmit` is the submit-button-ready signal: `valid && !validating &&
!hasFailedValidation`. Checking `valid` alone isn't enough, because it
says nothing about a check still in flight.

## When an async validator itself fails

A validator that throws or times out (wrap it in `.timeout(...)` for
that) doesn't become a `ValidationError` — that would read as "this
value is wrong", when really it's that the check couldn't run.
Instead, it sets `hasFailedValidation` (aggregating through the tree
like `validating` does), meant to drive one form-level banner —
"Some checks couldn't run, try again" — rather than a per-field
message. It also blocks `canSubmit`. The next value change, `reset()`,
or `validate()` call gives the check another chance.
