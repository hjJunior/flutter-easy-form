import 'validation_error.dart';

/// Validates a single typed value.
///
/// Returns `null` when [value] is valid, or a [ValidationError] describing
/// the failure otherwise. Used by [FormControl] and [FormArray]; a
/// [FormGroup]'s own cross-field rules are instead expressed by overriding
/// `validateSelf()`.
typedef Validator<T> = ValidationError? Function(T value);

/// Like [Validator], but for a check that can't complete synchronously
/// (e.g. asking an API whether a username is taken). Only [FormControl]
/// runs these, surfacing [FormControl.validating] while they're in flight.
typedef AsyncValidator<T> = Future<ValidationError?> Function(T value);
