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

  /// Pushes all unsynced cached records to Firestore in a single [WriteBatch].
  ///
  /// Each record produces two operations in the batch:
  /// 1. A new document in `routes/{routeId}/attendance/{auto-id}` (falls back
  ///    to the top-level `attendance` collection when [routeId] is empty).
  /// 2. A `status` field update on `students/{studentId}`.
  ///
  /// On a successful commit every synced record is marked `synced: true` in
  /// the Hive box. Throws if the Firestore commit fails so the caller can
  /// decide whether to retry.
  Future<void> syncOfflineData([FirebaseFirestore? firestore]) async {
    final fs = firestore ?? FirebaseFirestore.instance;
    final box = await _ensureBox();
    final unsynced = box.toMap().cast<String, CachedAttendanceRecord>()
        .values
        .where((r) => !r.synced)
        .toList();

    if (unsynced.isEmpty) return;

    final batch = fs.batch();

    for (final record in unsynced) {
      final statusValue = record.statusIndex == AttendanceStatus.boarded.index
          ? DriverFirestoreFields.boarded
          : DriverFirestoreFields.alighted;

      // Attendance subcollection write.
      final attendanceCollection = record.routeId.isNotEmpty
          ? fs.collection(DriverFirestorePaths.routeAttendanceCollection(record.routeId))
          : fs.collection(DriverFirestorePaths.attendance);
      final attendanceRef = attendanceCollection.doc();
      batch.set(attendanceRef, {
        DriverFirestoreFields.attendanceId: attendanceRef.id,
        DriverFirestoreFields.studentId: record.studentId,
        DriverFirestoreFields.routeId: record.routeId,
        DriverFirestoreFields.status: statusValue,
        DriverFirestoreFields.date: record.recordedAt.toIso8601String(),
        DriverFirestoreFields.timestamp: FieldValue.serverTimestamp(),
        DriverFirestoreFields.recordedBy: 'driver_app',
      });

      // Canonical student document status update.
      final studentRef = fs.collection('students').doc(record.studentId);
      batch.update(studentRef, {DriverFirestoreFields.status: statusValue});
    }

    await batch.commit();

    // Delete only the records that were part of this batch. Any new offline
    // entries written to the box during the commit are left untouched.
    for (final record in unsynced) {
      await box.delete(record.studentId);
    }
  }
}
