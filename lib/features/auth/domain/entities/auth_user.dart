import '../../../../shared/enums/user_role.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.onboardingComplete = true,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool onboardingComplete;
}
