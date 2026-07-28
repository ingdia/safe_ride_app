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

  @HiveField(6)
  final String routeId;

  CachedAttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.stopName,
    required this.statusIndex,
    required this.recordedAt,
    this.synced = false,
    this.routeId = '',
  });

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'studentName': studentName,
        'stopName': stopName,
        'statusIndex': statusIndex,
        'recordedAt': recordedAt.millisecondsSinceEpoch,
        'synced': synced,
        'routeId': routeId,
      };

  factory CachedAttendanceRecord.fromMap(Map<String, dynamic> map) =>
      CachedAttendanceRecord(
        studentId: map['studentId'] as String,
        studentName: map['studentName'] as String,
        stopName: map['stopName'] as String,
        statusIndex: map['statusIndex'] as int,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recordedAt'] as int),
        synced: map['synced'] as bool? ?? false,
        routeId: map['routeId'] as String? ?? '',
      );
}
