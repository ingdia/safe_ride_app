import '../../../../core/errors/exceptions.dart';
import '../../../../shared/enums/user_role.dart';
import '../models/auth_user_model.dart';

/// Simulates a remote auth data source with hardcoded mock users.
class AuthMockDatasource {
  /// Mock user database keyed by email.
  static const _mockUsers = [
    {
      'id': 'usr_001',
      'name': 'Alice Parent',
      'email': 'parent@test.com',
      'password': 'password123',
      'role': 'parent',
    },
    {
      'id': 'usr_002',
      'name': 'Bob Driver',
      'email': 'driver@test.com',
      'password': 'password123',
      'role': 'driver',
    },
    {
      'id': 'usr_003',
      'name': 'Carol Admin',
      'email': 'admin@test.com',
      'password': 'password123',
      'role': 'admin',
    },
  ];

  /// Simulates network latency.
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 800));

  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    await _delay();

    final match = _mockUsers.where(
      (u) =>
          u['email'] == email.trim().toLowerCase() &&
          u['password'] == password,
    );

    if (match.isEmpty) {
      throw const AuthException('Invalid email or password.');
    }

    return AuthUserModel.fromMap(match.first);
  }

  Future<AuthUserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _delay();

    final exists = _mockUsers.any(
      (u) => u['email'] == email.trim().toLowerCase(),
    );

    if (exists) {
      throw const AuthException('An account with this email already exists.');
    }

    // Mock: new users are always registered as parents
    return AuthUserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: UserRole.parent,
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _delay();

    final exists = _mockUsers.any(
      (u) => u['email'] == email.trim().toLowerCase(),
    );

    if (!exists) {
      throw const AuthException('No account found with this email address.');
    }
    // Mock: silently succeeds — reset link "sent"
  }
}
