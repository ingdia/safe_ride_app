import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../datasources/driver_firestore_fields.dart';
import '../datasources/driver_firestore_paths.dart';
import '../models/cached_attendance_record.dart';
import '../../domain/models/student.dart';

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

  /// Pushes all unsynced cached records to Firestore one record at a time.
  ///
  /// Each record produces two sequential writes:
  /// 1. A new document in `routes/{routeId}/attendance/{auto-id}` (falls back
  ///    to the top-level `attendance` collection when [routeId] is empty).
  /// 2. A `status` field update on `students/{studentId}`.
  ///
  /// Records are written individually so a failure on one (e.g. a network drop
  /// mid-sync) does not prevent the others from being committed. Only records
  /// whose writes succeed are removed from the cache; failed records remain and
  /// will be retried on the next call.
  Future<void> syncOfflineData([FirebaseFirestore? firestore]) async {
    final fs = firestore ?? FirebaseFirestore.instance;
    final box = await _ensureBox();
    final unsynced = box.toMap().cast<String, CachedAttendanceRecord>()
        .values
        .where((r) => !r.synced)
        .toList();

    if (unsynced.isEmpty) return;

    for (final record in unsynced) {
      final statusValue = record.statusIndex == AttendanceStatus.boarded.index
          ? DriverFirestoreFields.boarded
          : DriverFirestoreFields.alighted;

      try {
        final attendanceCollection = record.routeId.isNotEmpty
            ? fs.collection(DriverFirestorePaths.routeAttendanceCollection(record.routeId))
            : fs.collection(DriverFirestorePaths.attendance);
        final attendanceRef = attendanceCollection.doc();

        await attendanceRef.set({
          DriverFirestoreFields.attendanceId: attendanceRef.id,
          DriverFirestoreFields.studentId: record.studentId,
          DriverFirestoreFields.routeId: record.routeId,
          DriverFirestoreFields.status: statusValue,
          DriverFirestoreFields.date: record.recordedAt.toIso8601String(),
          DriverFirestoreFields.timestamp: FieldValue.serverTimestamp(),
          DriverFirestoreFields.recordedBy: 'driver_app',
        });

        await fs
            .collection('students')
            .doc(record.studentId)
            .update({DriverFirestoreFields.status: statusValue});

        // Both writes succeeded — safe to remove from cache.
        await box.delete(record.studentId);
      } catch (_) {
        // This record failed; leave it in the cache for the next retry.
        continue;
      }
    }
  }
}
