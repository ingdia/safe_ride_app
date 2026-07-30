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

  static UserRole fromString(String? s) {
    switch (s) {
      case 'driver':
        return UserRole.driver;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.parent;
    }
  }
}

enum DriverApprovalStatus { pending, approved, rejected }

extension DriverApprovalStatusX on DriverApprovalStatus {
  String get value {
    switch (this) {
      case DriverApprovalStatus.pending:
        return 'pending';
      case DriverApprovalStatus.approved:
        return 'approved';
      case DriverApprovalStatus.rejected:
        return 'rejected';
    }
  }

  static DriverApprovalStatus fromString(String? s) {
    switch (s) {
      case 'approved':
        return DriverApprovalStatus.approved;
      case 'rejected':
        return DriverApprovalStatus.rejected;
      default:
        return DriverApprovalStatus.pending;
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
  final DriverApprovalStatus? approvalStatus;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.approvalStatus,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final role = UserRoleX.fromString(data['role'] as String?);
    return UserModel(
      userId: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: role,
      createdAt:
          (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvalStatus: role == UserRole.driver
          ? DriverApprovalStatusX.fromString(
              data['approval_status'] as String?)
          : null,
    );
  }

  UserModel copyWith({DriverApprovalStatus? approvalStatus}) {
    return UserModel(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: createdAt,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }
}
