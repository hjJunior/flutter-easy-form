import '../validation/validation_error.dart';
import 'form_context.dart';
import 'form_node.dart';

/// A typed object composed of other [FormNode]s, declared by subclassing
/// and exposing real Dart properties — never a `Map<String, dynamic>`.
///
/// [TRoot] is the type of the root form of the tree this group belongs to.
/// The root form uses itself as [TRoot] and never passes [context]
/// explicitly; a nested group receives it from its parent instead, which
/// gives it typed access to the root through [context] without casts:
///
/// ```dart
/// class ArenaForm extends FormGroup<Arena, ArenaForm> {
///   final name = FormControl<String>(initialValue: '');
///
///   // `context` is an instance member, so a field that needs it (directly,
///   // or through a closure like `create` below) can't be a `final` field
///   // initializer — Dart forbids referencing `this` there. Assign it in
///   // the constructor body instead, where `context` is already valid.
///   late final FormArray<Court, CourtForm> courts;
///
///   ArenaForm() {
///     courts = FormArray<Court, CourtForm>(
///       create: () => CourtForm(context: context),
///     );
///   }
///
///   @override
///   Iterable<FormNode<Object?>> get children => [name, courts];
///
///   @override
///   Arena toValue() => Arena(name: name.value, courts: courts.value);
/// }
///
/// class CourtForm extends FormGroup<Court, ArenaForm> {
///   CourtForm({required super.context});
///
///   final capacity = FormControl<int>(initialValue: 0);
///
///   @override
///   Iterable<FormNode<Object?>> get children => [capacity];
///
///   @override
///   Court toValue() => Court(capacity: capacity.value);
///
///   @override
///   List<ValidationError> validateSelf() {
///     if (context.root.isBeachArena.value && capacity.value > 20) {
///       return [const ValidationError('Beach courts hold at most 20 people', code: 'invalid_capacity')];
///     }
///     return const [];
///   }
/// }
/// ```
abstract class FormGroup<T, TRoot> extends FormNode<T> {
  FormGroup({FormContext<TRoot>? context}) : _context = context;

  FormContext<TRoot>? _context;

  /// Typed access to the root of the form tree. The root form resolves
  /// this lazily to itself the first time it's read, by which point its
  /// own constructor has long finished — a nested group always receives
  /// it explicitly from its parent instead (see the class doc example).
  FormContext<TRoot> get context => _context ??= FormContext<TRoot>(this as TRoot);

  /// The group's own fields, used internally for propagation, validation
  /// and lifecycle. Never the public way to read values — use the typed
  /// properties directly, and [toValue] for the resulting model.
  @override
  Iterable<FormNode<Object?>> get children;

  /// Builds the typed domain model from the group's current field values.
  ///
  /// This is a best-effort projection: it does **not** check [valid] and
  /// never throws for an invalid or incomplete form — a required
  /// `FormControl<String>` left empty still contributes `''`, for
  /// instance. Call [validate] and check [valid] first if the result
  /// needs to be correct, not just buildable:
  ///
  /// ```dart
  /// form.validate();
  /// if (form.valid) {
  ///   final model = form.toValue();
  ///   // ...
  /// }
  /// ```
  T toValue();

  @override
  T get value => toValue();

  /// Override to validate this group's own fields against each other, or
  /// against [context.root]. Returns every violation found — empty when
  /// valid. A list, rather than a single nullable [ValidationError], so a
  /// group can report more than one cross-field rule failing at once, the
  /// same way its children can each contribute their own errors.
  List<ValidationError> validateSelf() => const [];

  @override
  List<ValidationError> get errors {
    if (disabled) return const [];
    return [...childrenErrors, ...validateSelf()];
  }
}
