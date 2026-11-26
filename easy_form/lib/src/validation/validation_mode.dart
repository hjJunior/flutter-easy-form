/// Controls when a [FormControl] reveals its errors and runs its
/// `asyncValidators` — inherited down the tree from whichever ancestor
/// last called `FormNode.setValidationMode`, or [ValidationMode.manual]
/// by default.
///
/// `errors`/`valid` themselves are always computed live regardless of
/// mode — this only governs *when* a control is willing to show what it
/// already knows, and when an async check actually runs rather than
/// just when it's displayed.
enum ValidationMode {
  /// Nothing validates until `FormNode.validate()` (typically on
  /// submit). Editing a field still hides the error that described its
  /// old value.
  manual,

  /// Every edit reveals the field's current errors immediately. An
  /// async validator still waits out `FormControl.asyncValidationDebounce`
  /// before actually running, so it isn't called on every keystroke.
  onUserInteraction,

  /// Leaving a field the user edited reveals it — call
  /// `FormControl.handleUnfocus()` when that happens (a bound
  /// `FormControlTextSync` does this for you automatically). Tabbing
  /// through a field, or leaving it unchanged, costs nothing: no
  /// reveal, no async check.
  onUnfocus,

  /// Behaves like [onUnfocus] until the field is first left after an
  /// edit; from then on it behaves like [onUserInteraction], so a fixed
  /// value's error disappears as soon as it's fixed, without needing
  /// another unfocus.
  afterFirstUnfocus,
}
