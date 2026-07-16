/// Represents a domain-level failure returned from repositories.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class EmergencyFailure extends Failure {
  const EmergencyFailure(super.message);
}
