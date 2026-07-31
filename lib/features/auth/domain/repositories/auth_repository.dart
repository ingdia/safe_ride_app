import '../entities/auth_user.dart';

abstract class AuthRepository {
  /// Returns the authenticated [AuthUser] on success.
  /// Throws [AuthException] on failure.
  Future<AuthUser> login({required String email, required String password});

  /// Returns the authenticated [AuthUser] after Google Sign-In.
  /// Throws [AuthException] on failure.
  Future<AuthUser> loginWithGoogle();

  /// Returns the currently signed-in [AuthUser] if available.
  Future<AuthUser?> currentUser();

  /// Returns the newly created [AuthUser] on success.
  /// Throws [AuthException] on failure.
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  });

  /// Sends a password reset link to [email].
  /// Throws [AuthException] on failure.
  Future<void> forgotPassword({required String email});

  /// Signs out the current user.
  Future<void> signOut();
}
