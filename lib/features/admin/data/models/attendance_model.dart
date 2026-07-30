import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { boarded, alighted, absent }

extension AttendanceStatusX on AttendanceStatus {
  String get value {
    switch (this) {
      case AttendanceStatus.boarded:
        return 'boarded';
      case AttendanceStatus.alighted:
        return 'alighted';
      case AttendanceStatus.absent:
        return 'absent';
    }
  }

  static AttendanceStatus fromString(String? s) {
    switch (s) {
      case 'boarded':
        return AttendanceStatus.boarded;
      case 'alighted':
        return AttendanceStatus.alighted;
      default:
        return AttendanceStatus.absent;
    }
  }
}

class AttendanceModel {
  final String attendanceId;
  final String studentId;
  final String routeId;
  final String busId;
  final AttendanceStatus status;
  final String date;
  final DateTime timestamp;
  final String recordedBy;

  const AttendanceModel({
    required this.attendanceId,
    required this.studentId,
    required this.routeId,
    required this.busId,
    required this.status,
    required this.date,
    required this.timestamp,
    required this.recordedBy,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      attendanceId: doc.id,
      studentId: data['student_id'] as String? ?? '',
      routeId: data['route_id'] as String? ?? '',
      busId: data['bus_id'] as String? ?? '',
      status: AttendanceStatusX.fromString(data['status'] as String?),
      date: data['date'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recordedBy: data['recorded_by'] as String? ?? '',
    );
  }
}
