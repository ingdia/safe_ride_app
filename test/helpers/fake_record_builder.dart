import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';

CachedAttendanceRecord buildRecord(
  String studentId,
  AttendanceStatus status, {
  String routeId = '',
  bool synced = false,
}) =>
    CachedAttendanceRecord(
      studentId: studentId,
      studentName: 'Test Student',
      stopName: 'Oak Street',
      statusIndex: status.index,
      recordedAt: DateTime(2024, 1, 1),
      routeId: routeId,
      synced: synced,
    );
