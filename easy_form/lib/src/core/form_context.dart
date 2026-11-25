/// Typed, read-only access to the root [FormGroup] of a form tree.
///
/// Exists so a nested [FormGroup] can reach the root form to implement
/// cross-field rules that span more than its own direct children — e.g. a
/// court's capacity rule that depends on the arena's category. It is
/// intentionally minimal and not a dependency container: it only hands out
/// [root], typed, with no further indirection.
class FormContext<TRoot> {
  const FormContext(this.root);

  final TRoot root;
}
