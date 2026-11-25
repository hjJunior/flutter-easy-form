/// Thrown by [FormGroup.validateSelf] to report a cross-field business rule
/// violation (one involving more than a single control, possibly reaching
/// the root form through [FormGroup.context]).
///
/// Caught internally while computing [FormGroup.errors] and translated into
/// a single [ValidationError] for that group — at most one per group per
/// validation pass, the same way a single `FormField.validator` in Flutter
/// surfaces one message at a time.
class FormValidationException implements Exception {
  const FormValidationException({required this.code, this.message});

  final String code;
  final String? message;

  @override
  String toString() => 'FormValidationException($code: ${message ?? code})';
}
