enum ParentChildStatus { pending, approved, rejected }

class ParentChildEntity {
  const ParentChildEntity({
    required this.id,
    required this.fullName,
    required this.grade,
    required this.status,
    this.schoolId,
    this.busId,
    this.busNumber,
    this.pickupStop,
    this.driverName,
    this.driverPhone,
  });

  final String id;
  final String fullName;
  final String grade;
  final ParentChildStatus status;
  final String? schoolId;
  final String? busId;
  final String? busNumber;
  final String? pickupStop;
  final String? driverName;
  final String? driverPhone;

  bool get isApproved => status == ParentChildStatus.approved;
  bool get isAssignedToBus => busId != null && busId!.isNotEmpty;

  ParentChildEntity copyWith({String? fullName, String? grade}) {
    return ParentChildEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      grade: grade ?? this.grade,
      status: status,
      schoolId: schoolId,
      busId: busId,
      busNumber: busNumber,
      pickupStop: pickupStop,
      driverName: driverName,
      driverPhone: driverPhone,
    );
  }
}
