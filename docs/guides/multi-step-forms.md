# Creating multi-step forms

A multi-step form is still a single form tree — one `FormGroup`
instance whose fields happen to be spread across several screens or
pages. Group each step's own fields into their own nested `FormGroup`
(see [How to structure your project](project-structure.md) for the
`TRoot` wiring that needs), and drive which one is visible with
whatever navigation you already use (`PageView`, a `Stepper`, your own
index):

```dart
class SignupForm extends FormGroup<Signup, SignupForm> {
  late final AccountStep account;
  late final ProfileStep profile;

  SignupForm() {
    account = AccountStep(context: context);
    profile = ProfileStep(context: context);
  }

  @override
  Iterable<FormNode<Object?>> get children => [account, profile];

  @override
  Signup toValue() => Signup(account: account.toValue(), profile: profile.toValue());
}
```

## Validating across steps

The problem a multi-step form adds: `validate()` can fail on a field
that isn't the one currently on screen — it belongs to a previous step.
`validate()` still validates the whole tree regardless of what's
mounted, and `validationErrors` keys every error by the exact node that
reported it, so you can find which step owns it and navigate there:

```dart
Future<void> submit() async {
  await form.validate();
  if (form.canSubmit) {
    await api.signup(form.toValue());
    return;
  }

  final invalidNode = form.validationErrors.keys.first;
  final stepIndex = form.account.children.contains(invalidNode) || invalidNode == form.account
      ? 0
      : 1;

  pageController.jumpToPage(stepIndex);
  if (invalidNode is FormControl) invalidNode.requestAttention();
}
```

`requestAttention()` (focus + scroll-into-view + highlight) can be
called before the target step actually mounts: `requestFocus()` and
`ensureVisible()` both keep the request pending and honor it the moment
the field's widget attaches — which `jumpToPage` triggers on the next
frame. See [`FormControl`](../reference/form-control.md) for what each
of the three does on its own, and [Using Flutter
widgets](../integrate-your-stack/flutter-widgets.md) for how a field
wires itself up to answer these requests in the first place.

If a step fails its own `validateSelf()` (a cross-field rule, not tied
to one field), there's no single `FormControl` to focus — `highlight()`
on the step's own `FormGroup` is the fallback, since it's defined on
every `FormNode`:

```dart
void _bringToAttention(FormNode<Object?> node) {
  if (node is FormControl) {
    node.requestAttention();
  } else {
    node.highlight();
  }
}
```
