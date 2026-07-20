import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../models/cached_attendance_record.dart';

class AttendanceCacheService {
  Box<CachedAttendanceRecord> get _box =>
      Hive.box<CachedAttendanceRecord>(HiveBoxes.offlineAttendance);

  /// Saves or overwrites the cached record for [studentId].
  Future<void> saveRecord(CachedAttendanceRecord record) async {
    await _box.put(record.studentId, record);
  }

  /// Returns all cached records, keyed by studentId.
  Map<String, CachedAttendanceRecord> loadAll() {
    return Map.unmodifiable(_box.toMap().cast<String, CachedAttendanceRecord>());
  }

  /// Removes the record for [studentId].
  Future<void> deleteRecord(String studentId) async {
    await _box.delete(studentId);
  }

  /// Clears all cached attendance records.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
