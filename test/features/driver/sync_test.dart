import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:safe_ride_app/core/firebase/firebase_collections.dart';
import 'package:safe_ride_app/features/driver/data/datasources/attendance_cache_service.dart';
import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';

import '../../helpers/fake_record_builder.dart';

/// Wraps [AttendanceCacheService] and injects a per-record failure for
/// [failStudentId] by mirroring the production sync logic directly: resolve
/// the record's route -> bus -> active trip, set the trip's studentEvents
/// entry, update the student's attendanceStatus, then drop it from cache —
/// except for [failStudentId], which is left in the cache to simulate a
/// failed write.
class _PartialFailCacheService extends AttendanceCacheService {
  _PartialFailCacheService(this.failStudentId, this._goodFs);
  final String failStudentId;
  final FakeFirebaseFirestore _goodFs;

  @override
  Future<void> syncOfflineData([firestore]) async {
    final box = await super.loadAll();
    for (final record in box.values.where((r) => !r.synced)) {
      if (record.studentId == failStudentId) {
        // Simulate failure — leave in cache.
        continue;
      }

      final statusValue =
          record.statusIndex == AttendanceStatus.boarded.index ? 'boarded' : 'alighted';

      if (record.routeId.isNotEmpty) {
        final routeDoc =
            await _goodFs.collection(FirebaseCollections.routes).doc(record.routeId).get();
        final busId = routeDoc.data()?['busId'] as String?;
        if (busId != null && busId.isNotEmpty) {
          final tripQuery = await _goodFs
              .collection(FirebaseCollections.trips)
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

      await _goodFs
          .collection(FirebaseCollections.students)
          .doc(record.studentId)
          .set({'attendanceStatus': statusValue}, SetOptions(merge: true));

      await deleteRecord(record.studentId);
    }
  }
}

void main() {
  late Directory tempDir;
  late AttendanceCacheService cache;
  late FakeFirebaseFirestore fakeFs;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_sync_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CachedAttendanceRecordAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    cache = AttendanceCacheService();
    fakeFs = FakeFirebaseFirestore();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('offline_attendance');
  });

  /// Seeds a `routes/{routeId}` doc with [busId] and an in-progress
  /// `trips` doc for that bus, returning the trip id.
  Future<String> seedActiveTrip({required String routeId, required String busId}) async {
    await fakeFs.collection(FirebaseCollections.routes).doc(routeId).set({'busId': busId});
    final tripRef = await fakeFs.collection(FirebaseCollections.trips).add({
      'busId': busId,
      'routeId': routeId,
      'status': 'inProgress',
      'studentEvents': <String, dynamic>{},
    });
    return tripRef.id;
  }

  group('AttendanceCacheService.syncOfflineData', () {
    test('writes into the active trip studentEvents and updates attendanceStatus', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'approved'});
      final tripId = await seedActiveTrip(routeId: 'route_1', busId: 'bus_1');

      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded, routeId: 'route_1'));
      await cache.syncOfflineData(fakeFs);

      final tripDoc = await fakeFs.collection(FirebaseCollections.trips).doc(tripId).get();
      expect(tripDoc.data()!['studentEvents'], {'s1': 'boarded'});

      final studentDoc = await fakeFs.collection('students').doc('s1').get();
      expect(studentDoc.data()!['attendanceStatus'], 'boarded');
      // The approval-status field must never be touched by an attendance sync.
      expect(studentDoc.data()!['status'], 'approved');
    });

    test('removes successfully synced records from the cache after commit', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'approved'});
      await seedActiveTrip(routeId: 'route_1', busId: 'bus_1');

      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded, routeId: 'route_1'));
      await cache.syncOfflineData(fakeFs);

      expect((await cache.loadAll()).containsKey('s1'), isFalse);
    });

    test('preserves records added to the cache after the batch snapshot was taken', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'approved'});
      await fakeFs.collection('students').doc('s2').set({'name': 'Bob', 'status': 'approved'});
      await seedActiveTrip(routeId: 'route_1', busId: 'bus_1');
      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded, routeId: 'route_1'));

      await cache.saveRecord(buildRecord('s2', AttendanceStatus.absent, routeId: 'route_1'));

      await cache.syncOfflineData(fakeFs);

      expect((await cache.loadAll()).containsKey('s1'), isFalse);
      expect((await cache.loadAll()).containsKey('s2'), isFalse);

      await cache.saveRecord(buildRecord('s2', AttendanceStatus.boarded, routeId: 'route_1'));
      expect((await cache.loadAll()).containsKey('s2'), isTrue);
    });

    test('writes all records when all succeed', () async {
      await seedActiveTrip(routeId: 'route_1', busId: 'bus_1');
      for (final id in ['s1', 's2', 's3']) {
        await fakeFs.collection('students').doc(id).set({'name': id, 'status': 'approved'});
        await cache.saveRecord(buildRecord(id, AttendanceStatus.boarded, routeId: 'route_1'));
      }

      await cache.syncOfflineData(fakeFs);

      final tripDocs = await fakeFs.collection(FirebaseCollections.trips).get();
      final events = tripDocs.docs.first.data()['studentEvents'] as Map;
      expect(events.length, 3);
      expect((await cache.loadAll()), isEmpty);
    });

    test('keeps failed record in cache and clears successful ones on partial failure', () async {
      for (final id in ['s1', 's2', 's3']) {
        await fakeFs.collection('students').doc(id).set({'name': id, 'status': 'approved'});
      }

      final partialCache = _PartialFailCacheService('s2', fakeFs);
      for (final id in ['s1', 's2', 's3']) {
        await partialCache.saveRecord(buildRecord(id, AttendanceStatus.boarded, routeId: 'route_1'));
      }

      await partialCache.syncOfflineData();

      final remaining = await partialCache.loadAll();
      expect(remaining.containsKey('s1'), isFalse);
      expect(remaining.containsKey('s2'), isTrue); // failed — kept for retry
      expect(remaining.containsKey('s3'), isFalse);
    });

    test('retries failed record on next syncOfflineData call', () async {
      for (final id in ['s1', 's2']) {
        await fakeFs.collection('students').doc(id).set({'name': id, 'status': 'approved'});
      }

      final partialCache = _PartialFailCacheService('s2', fakeFs);
      for (final id in ['s1', 's2']) {
        await partialCache.saveRecord(buildRecord(id, AttendanceStatus.boarded, routeId: 'route_1'));
      }
      await partialCache.syncOfflineData();
      expect((await partialCache.loadAll()).containsKey('s2'), isTrue);

      await cache.saveRecord(buildRecord('s2', AttendanceStatus.boarded, routeId: 'route_1'));
      await cache.syncOfflineData(fakeFs);
      expect((await cache.loadAll()), isEmpty);
    });

    test('gracefully skips the trip write when no route/trip can be resolved', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'approved'});

      await cache.saveRecord(buildRecord('s1', AttendanceStatus.absent, routeId: ''));
      await cache.syncOfflineData(fakeFs);

      final studentDoc = await fakeFs.collection('students').doc('s1').get();
      expect(studentDoc.data()!['attendanceStatus'], 'alighted');
      expect((await cache.loadAll()).containsKey('s1'), isFalse);
    });

    test('skips already-synced records', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'approved'});
      await seedActiveTrip(routeId: 'route_1', busId: 'bus_1');

      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded, routeId: 'route_1', synced: true));
      await cache.syncOfflineData(fakeFs);

      final tripDocs = await fakeFs.collection(FirebaseCollections.trips).get();
      final events = tripDocs.docs.first.data()['studentEvents'] as Map;
      expect(events, isEmpty);
    });

    test('does nothing when cache is empty', () async {
      await cache.syncOfflineData(fakeFs);

      final tripDocs = await fakeFs.collection(FirebaseCollections.trips).get();
      expect(tripDocs.docs, isEmpty);
    });
  });
}
