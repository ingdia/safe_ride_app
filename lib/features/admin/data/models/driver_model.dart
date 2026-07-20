enum DriverApprovalStatus { pending, approved, rejected }

class DriverModel {
  final String driverId;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final DateTime submittedAt;
  final DriverApprovalStatus status;

  const DriverModel({
    required this.driverId,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.submittedAt,
    this.status = DriverApprovalStatus.pending,
  });

  DriverModel copyWith({
    String? driverId,
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    DateTime? submittedAt,
    DriverApprovalStatus? status,
  }) {
    return DriverModel(
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
    );
  }
}
