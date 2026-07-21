import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../models/cached_attendance_record.dart';

class AttendanceCacheService {
  Box<CachedAttendanceRecord>? _box;

  Future<Box<CachedAttendanceRecord>> _ensureBox() async {
    if (_box != null) return _box!;

    try {
      _box ??= await Hive.openBox<CachedAttendanceRecord>(HiveBoxes.offlineAttendance);
    } on HiveError catch (_) {
      _box = Hive.box<CachedAttendanceRecord>(HiveBoxes.offlineAttendance);
    }

    return _box!;
  }

  /// Saves or overwrites the cached record for [studentId].
  Future<void> saveRecord(CachedAttendanceRecord record) async {
    final box = await _ensureBox();
    await box.put(record.studentId, record);
  }

  /// Returns all cached records, keyed by studentId.
  Future<Map<String, CachedAttendanceRecord>> loadAll() async {
    final box = await _ensureBox();
    return Map.unmodifiable(box.toMap().cast<String, CachedAttendanceRecord>());
  }

  /// Removes the record for [studentId].
  Future<void> deleteRecord(String studentId) async {
    final box = await _ensureBox();
    await box.delete(studentId);
  }

  /// Clears all cached attendance records.
  Future<void> clearAll() async {
    final box = await _ensureBox();
    await box.clear();
  }
}
