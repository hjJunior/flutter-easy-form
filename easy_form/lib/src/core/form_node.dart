import 'package:flutter/foundation.dart';

import '../validation/validation_error.dart';

/// Base contract shared by [FormControl], [FormGroup] and [FormArray].
///
/// Centralizes state (dirty/touched/enabled), validation, reset and the
/// parent/child wiring used to bubble change notifications up the tree.
/// Subclasses never need to re-implement that plumbing: they only provide
/// [value], [ownErrors] and, when they have descendants, [children].
abstract class FormNode<T> extends ChangeNotifier {
  bool _ownDirty = false;
  bool _ownTouched = false;
  bool _enabled = true;
  FormNode<Object?>? _parent;

  /// The current typed value held by this node.
  T get value;

  /// This node's own errors, not counting any descendant's — what
  /// [FormControl] gets from its validators, [FormGroup] from
  /// `validateSelf()`, [FormArray] from its own list-level validators.
  /// Empty by default.
  List<ValidationError> get ownErrors => const [];

  /// [ownErrors] plus every descendant's own errors, or none while
  /// [disabled]. This is almost always what you want to check a node's
  /// validity; use [ownErrors] (or [validationErrors], to keep each
  /// error tied to the node that reported it) when you need to tell a
  /// node's own errors apart from its descendants'.
  List<ValidationError> get errors {
    if (disabled) return const [];
    return [...childrenErrors, ...ownErrors];
  }

  bool get valid => errors.isEmpty;
  bool get invalid => !valid;

  /// This node's own first error (see [ownErrors]), once it's been
  /// [touched] — otherwise `null`. The "show one message, only after the
  /// user has interacted" convention most field widgets want; read
  /// [ownErrors] directly for anything more specific (e.g. every error
  /// at once, or regardless of [touched]).
  String? get displayError {
    if (!touched) return null;
    final errors = ownErrors;
    return errors.isEmpty ? null : errors.first.message;
  }

  /// Direct descendants of this node. Empty for leaf nodes such as
  /// [FormControl]. [FormGroup] and [FormArray] override this.
  Iterable<FormNode<Object?>> get children => const [];

  bool get dirty => _ownDirty || children.any((child) => child.dirty);
  bool get pristine => !dirty;

  bool get touched => _ownTouched || children.any((child) => child.touched);
  bool get untouched => !touched;

  /// Whether an async validator is still running somewhere in this
  /// subtree. Only [FormControl] has async validators of its own; groups
  /// and arrays aggregate it from their descendants, the same way
  /// [dirty] and [touched] do. Not reflected by [valid]/[invalid] — an
  /// async error only shows up in [errors] once its validator resolves.
  /// See [canSubmit] for a submit-button-ready signal that does account
  /// for it.
  bool get validating => children.any((child) => child.validating);

  /// Whether an async validator somewhere in this subtree threw or timed
  /// out instead of resolving normally — the check itself failed, which
  /// is different from it resolving to a [ValidationError]. Doesn't add
  /// anything to [errors] (that would read as "this field's value is
  /// wrong", when really it's that the check couldn't run); meant to
  /// drive a single form-level banner instead. Aggregates through groups
  /// and arrays the same way [validating] does.
  bool get hasFailedValidation => children.any((child) => child.hasFailedValidation);

  /// A submit-button-ready signal: every known error-free, and nothing
  /// left to resolve. `true` on a quiet form nobody has touched yet;
  /// `false` while [validating] or [hasFailedValidation] — a snapshot
  /// can't promise what an in-flight (or failed) check would have said.
  /// `await validate()` is what actually settles every async validator
  /// in this subtree before you trust [valid].
  bool get canSubmit => valid && !validating && !hasFailedValidation;

  bool get enabled => _enabled;
  bool get disabled => !_enabled;

  /// The node that adopted this one, if any. A node belongs to at most one
  /// parent at a time.
  FormNode<Object?>? get parent => _parent;

  /// Marks this node (and every descendant) as touched, then notifies
  /// listeners so the UI can reveal validation errors.
  void markAsTouched() {
    _ownTouched = true;
    for (final child in children) {
      child.markAsTouched();
    }
    notifyListeners();
  }

  /// Marks this node as touched and, for a [FormControl] with async
  /// validators, (re-)runs and awaits them — recursively: the returned
  /// future only resolves once every async validator anywhere in this
  /// subtree has settled. That's the guarantee [canSubmit] itself can't
  /// give as a synchronous snapshot.
  Future<void> validate() async {
    markAsTouched();
    await Future.wait(children.map((child) => child.validate()));
  }

  /// Restores this node (and every descendant) to its initial state:
  /// original value, `pristine`, `untouched`. Does not restore a
  /// [FormArray]'s initial item count — see the library's roadmap.
  void reset() {
    _ownDirty = false;
    _ownTouched = false;
    for (final child in children) {
      child.reset();
    }
    notifyListeners();
  }

  /// Makes this node's current value (and, transitively, every
  /// descendant's) the new baseline [reset] returns to, and clears
  /// [dirty]. Useful after loading an existing model into the form by
  /// hand (there's no `fromValue`/`patchValue` in this library — a plain
  /// Dart setter on each control already works and already notifies):
  /// call this once afterwards so `reset()` goes back to the loaded
  /// state instead of the form's original, empty one.
  void markAsInitial() {
    _ownDirty = false;
    for (final child in children) {
      child.markAsInitial();
    }
    notifyListeners();
  }

  void enable() {
    _enabled = true;
    for (final child in children) {
      child.enable();
    }
    notifyListeners();
  }

  void disable() {
    _enabled = false;
    for (final child in children) {
      child.disable();
    }
    notifyListeners();
  }

  /// Every error anywhere in this subtree, keyed by the node that
  /// reported it directly — unlike [errors], which already flattens a
  /// [FormGroup]'s or [FormArray]'s descendants' errors into its own
  /// list. Handy for a form-level error summary that needs to know which
  /// field each message belongs to; a node with no error of its own
  /// (including a [disabled] one) is left out.
  Map<FormNode<Object?>, List<ValidationError>> get validationErrors {
    final result = <FormNode<Object?>, List<ValidationError>>{};

    void visit(FormNode<Object?> node) {
      if (!node.disabled) {
        final own = node.ownErrors;
        if (own.isNotEmpty) result[node] = own;
      }
      for (final child in node.children) {
        visit(child);
      }
    }

    visit(this);
    return result;
  }

  /// Marks only this node (not descendants) as having a changed value.
  /// Called by [FormControl] when its value is set.
  @protected
  void markAsDirty() => _ownDirty = true;

  /// Each direct child's own [errors] (which, for a child that is itself
  /// a [FormGroup] or [FormArray], already includes its descendants').
  @protected
  Iterable<ValidationError> get childrenErrors => children.expand((child) => child.errors);

  /// Adopts every not-yet-adopted direct child, cascading down the tree as
  /// each child's own listener is attached (see [addListener]).
  ///
  /// Adoption is lazy, triggered on first listen rather than at
  /// construction time, because a [FormGroup] field whose value depends on
  /// [FormGroup.context] (an instance member) cannot be built inside an
  /// inline field initializer — it has to be assigned in the constructor
  /// body, which runs after the superclass constructor. Deferring adoption
  /// this way means it never matters which of the two a child field uses.
  @protected
  void ensureChildrenAdopted() {
    for (final child in children) {
      if (child.parent == null) {
        adopt(child);
      }
    }
  }

  @override
  void addListener(VoidCallback listener) {
    ensureChildrenAdopted();
    super.addListener(listener);
  }

  /// Registers [child] as a descendant of this node: records the parent
  /// link and forwards its notifications upward.
  @protected
  void adopt(FormNode<Object?> child) {
    assert(
      child._parent == null,
      'This FormNode already belongs to another parent. '
      'A node cannot be shared between two parents.',
    );
    child._parent = this;
    child.addListener(_onChildNotified);
  }

  /// Reverses [adopt]: detaches [child] and disposes it, since a node
  /// removed from the tree (e.g. FormArray.removeAt) is never reused.
  @protected
  void abandon(FormNode<Object?> child) {
    child.removeListener(_onChildNotified);
    child._parent = null;
    child.dispose();
  }

  void _onChildNotified() => notifyListeners();

  @override
  void dispose() {
    for (final child in children) {
      child.dispose();
    }
    super.dispose();
  }
}
