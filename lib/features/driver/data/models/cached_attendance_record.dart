import 'package:hive/hive.dart';

part 'cached_attendance_record.g.dart';

@HiveType(typeId: 0)
class CachedAttendanceRecord extends HiveObject {
  @HiveField(0)
  final String studentId;

  @HiveField(1)
  final String studentName;

  @HiveField(2)
  final String stopName;

  @HiveField(3)
  final int statusIndex; // maps to AttendanceStatus enum ordinal

  @HiveField(4)
  final DateTime recordedAt;

  @HiveField(5)
  final bool synced;

  CachedAttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.stopName,
    required this.statusIndex,
    required this.recordedAt,
    this.synced = false,
  });
}
