import 'package:safe_ride_app/features/driver/data/datasources/attendance_cache_service.dart';
import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';

/// In-memory stub — no Hive box required in unit tests.
class FakeAttendanceCacheService implements AttendanceCacheService {
  final _store = <String, CachedAttendanceRecord>{};

  @override
  Future<void> saveRecord(CachedAttendanceRecord record) async {
    _store[record.studentId] = record;
  }

  @override
  Map<String, CachedAttendanceRecord> loadAll() => Map.unmodifiable(_store);

  @override
  Future<void> deleteRecord(String studentId) async {
    _store.remove(studentId);
  }

  @override
  Future<void> clearAll() async => _store.clear();
}
