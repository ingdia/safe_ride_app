enum UserRole { parent, driver, admin }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.parent:
        return 'parent';
      case UserRole.driver:
        return 'driver';
      case UserRole.admin:
        return 'admin';
    }
  }
}

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
  });
}
