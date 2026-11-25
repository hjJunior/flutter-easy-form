import 'validation_error.dart';

/// Validates a single typed value.
///
/// Returns `null` when [value] is valid, or a [ValidationError] describing
/// the failure otherwise. Used by [FormControl] and [FormArray]; a
/// [FormGroup]'s own cross-field rules are instead expressed by overriding
/// `validateSelf()`.
typedef Validator<T> = ValidationError? Function(T value);
