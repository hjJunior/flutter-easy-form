import 'package:flutter/foundation.dart';

import '../validation/validation_error.dart';

/// Base contract shared by [FormControl], [FormGroup] and [FormArray].
///
/// Centralizes state (dirty/touched/enabled), validation, reset and the
/// parent/child wiring used to bubble change notifications up the tree.
/// Subclasses never need to re-implement that plumbing: they only provide
/// [value], [errors] and, when they have descendants, [children].
abstract class FormNode<T> extends ChangeNotifier {
  bool _ownDirty = false;
  bool _ownTouched = false;
  bool _enabled = true;
  FormNode<Object?>? _parent;

  /// The current typed value held by this node.
  T get value;

  /// Validation errors for this node. Implementations decide whether that
  /// includes descendants (groups/arrays do, via [childrenErrors]).
  List<ValidationError> get errors;

  bool get valid => errors.isEmpty;
  bool get invalid => !valid;

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
  bool get pending => children.any((child) => child.pending);

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

  /// Forces revalidation to surface, i.e. marks the node as touched.
  /// Sync errors are always computed live from [errors]; a [FormControl]
  /// with async validators also (re-)runs them.
  void validate() => markAsTouched();

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

  /// Marks only this node (not descendants) as having a changed value.
  /// Called by [FormControl] when its value is set.
  @protected
  void markAsDirty() => _ownDirty = true;

  /// Errors contributed by [children], or none while [disabled]. Handy for
  /// [FormGroup] and [FormArray] to combine with their own validators.
  @protected
  Iterable<ValidationError> get childrenErrors =>
      disabled ? const [] : children.expand((child) => child.errors);

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
