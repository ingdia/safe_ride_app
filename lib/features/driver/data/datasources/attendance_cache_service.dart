import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../core/storage/hive_boxes.dart';
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
  /// Each record produces up to two writes:
  /// 1. If an in-progress trip can be resolved for the record's route (via
  ///    the route's `busId`), the matching `trips/{tripId}.studentEvents`
  ///    entry is set — this is what the parent app is watching.
  /// 2. `students/{studentId}.attendanceStatus` is updated (a distinct field
  ///    from `status`, which holds the school-approval state and must never
  ///    be overwritten by an attendance mark).
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
      final statusValue =
          record.statusIndex == AttendanceStatus.boarded.index ? 'boarded' : 'alighted';

      try {
        if (record.routeId.isNotEmpty) {
          final routeDoc =
              await fs.collection(FirebaseCollections.routes).doc(record.routeId).get();
          final busId = routeDoc.data()?['busId'] as String?;
          final schoolId = routeDoc.data()?['schoolId'] as String?;
          if (busId != null && busId.isNotEmpty && schoolId != null && schoolId.isNotEmpty) {
            // The `trips` rule gates reads on `schoolId`, so it must be an
            // explicit filter here too — filtering by `busId` alone is
            // rejected outright by Firestore, not just empty.
            final tripQuery = await fs
                .collection(FirebaseCollections.trips)
                .where('schoolId', isEqualTo: schoolId)
                .where('busId', isEqualTo: busId)
                .where('status', isEqualTo: 'inProgress')
                .limit(1)
                .get();
            if (tripQuery.docs.isNotEmpty) {
              await tripQuery.docs.first.reference.update({
                'studentEvents.${record.studentId}':
                    statusValue == 'boarded' ? 'boarded' : 'droppedOff',
              });
            }
          }
        }

        await fs
            .collection(FirebaseCollections.students)
            .doc(record.studentId)
            .set({'attendanceStatus': statusValue}, SetOptions(merge: true));

        // Both writes succeeded (or there was no active trip to update) —
        // safe to remove from cache.
        await box.delete(record.studentId);
      } catch (_) {
        // This record failed; leave it in the cache for the next retry.
        continue;
      }
    }
  }
}
