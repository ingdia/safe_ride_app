import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? schoolId;

  /// Only meaningful for drivers — presence unlocks driver login.
  final String? busId;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.schoolId,
    this.busId,
  });

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final roleName = d['role'] as String? ?? 'parent';
    return UserModel(
      userId: doc.id,
      name: d['name'] as String? ?? '',
      email: d['email'] as String? ?? '',
      phone: d['phone'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.value == roleName,
        orElse: () => UserRole.parent,
      ),
      schoolId: d['schoolId'] as String?,
      busId: d['busId'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
