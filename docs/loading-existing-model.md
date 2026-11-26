# Loading an existing model

There's no `fromValue`/`patchValue` in this library: `FormGroup` is a plain
Dart class, so a plain function that sets each control's `value` already
works, and already notifies:

```dart
void applyArena(ArenaForm form, Arena arena) {
  form.name.value = arena.name;
  form.international.value = arena.international;
  for (final contact in arena.contacts) {
    form.contacts.add();
    form.contacts.last.name.value = contact.name;
    form.contacts.last.email.value = contact.email;
  }
}
```

The one thing the library does for you: after loading, call
`form.markAsInitial()` so `reset()` goes back to what you just loaded
instead of the form's original, empty state. It rebases every
descendant's `initialValue` to its current value and clears `dirty`,
recursively.

```dart
applyArena(form, existingArena);
form.markAsInitial();

form.name.value = 'something else';
form.reset(); // back to existingArena.name, not ''
```
