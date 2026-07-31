import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/user_role.dart';

class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.schoolId,
    this.busId,
    this.onboardingComplete = false,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? schoolId;

  /// Set only on driver accounts once an admin assigns them a bus.
  /// Its presence is what unlocks driver login.
  final String? busId;
  final bool onboardingComplete;

  bool get isAssignedDriver => role == UserRole.driver && busId != null && busId!.isNotEmpty;

  factory UserEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final roleName = d['role'] as String? ?? UserRole.parent.name;
    return UserEntity(
      id: doc.id,
      name: d['name'] as String? ?? '',
      email: d['email'] as String? ?? '',
      phone: d['phone'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == roleName,
        orElse: () => UserRole.parent,
      ),
      schoolId: d['schoolId'] as String?,
      busId: d['busId'] as String?,
      onboardingComplete: d['onboardingComplete'] as bool? ?? false,
    );
  }
}
