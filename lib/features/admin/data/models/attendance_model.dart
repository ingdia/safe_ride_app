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
}
