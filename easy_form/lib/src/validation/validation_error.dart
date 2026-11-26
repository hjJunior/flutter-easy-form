class ValidationError {
  const ValidationError(this.message, {this.code});

  final String message;
  final String? code;

  @override
  bool operator ==(Object other) =>
      other is ValidationError && other.message == message && other.code == code;

  @override
  int get hashCode => Object.hash(message, code);

  @override
  String toString() => 'ValidationError(${code ?? '-'}: $message)';
}
