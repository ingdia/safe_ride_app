import 'package:cloud_firestore/cloud_firestore.dart';

enum StudentStatus { pending, approved, rejected }

class StudentEntity {
  const StudentEntity({
    required this.id,
    required this.name,
    required this.grade,
    required this.schoolId,
    required this.parentId,
    required this.status,
    this.busId,
    this.routeId,
    this.stopName,
    this.driverName,
    this.driverPhone,
    this.busNumber,
    this.requestedStop,
  });

  final String id;
  final String name;
  final String grade;
  final String schoolId;
  final String parentId;
  final StudentStatus status;
  final String? busId;
  final String? routeId;
  final String? stopName;
  final String? driverName;
  final String? driverPhone;
  final String? busNumber;

  /// Free-text pickup location the parent asked for at registration —
  /// context for the admin when picking the closest real stop on an actual
  /// route; not itself an assignment.
  final String? requestedStop;

  bool get isApproved => status == StudentStatus.approved;
  bool get isPending => status == StudentStatus.pending;

  factory StudentEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return StudentEntity(
      id: doc.id,
      name: d['name'] as String? ?? '',
      grade: d['grade'] as String? ?? '',
      schoolId: d['schoolId'] as String? ?? '',
      parentId: d['parentId'] as String? ?? '',
      status: _statusFrom(d['status'] as String?),
      busId: d['busId'] as String?,
      routeId: d['routeId'] as String?,
      stopName: d['stopName'] as String?,
      driverName: d['driverName'] as String?,
      driverPhone: d['driverPhone'] as String?,
      busNumber: d['busNumber'] as String?,
      requestedStop: d['requestedStop'] as String?,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'name': name,
        'grade': grade,
        'schoolId': schoolId,
        'parentId': parentId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

  static StudentStatus _statusFrom(String? value) {
    switch (value) {
      case 'approved':
        return StudentStatus.approved;
      case 'rejected':
        return StudentStatus.rejected;
      default:
        return StudentStatus.pending;
    }
  }
}
