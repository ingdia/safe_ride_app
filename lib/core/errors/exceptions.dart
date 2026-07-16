class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class EmergencyException implements Exception {
  const EmergencyException(this.message);
  final String message;

  @override
  String toString() => message;
}
