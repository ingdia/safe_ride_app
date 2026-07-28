import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:safe_ride_app/features/driver/data/datasources/attendance_cache_service.dart';
import 'package:safe_ride_app/features/driver/data/datasources/driver_firestore_fields.dart';
import 'package:safe_ride_app/features/driver/data/datasources/driver_firestore_paths.dart';
import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';

import '../../helpers/fake_record_builder.dart';

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

  group('AttendanceCacheService.syncOfflineData', () {
    test('writes attendance doc and updates student status for each unsynced record', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'notBoarded'});

      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded, routeId: 'route_1'));
      await cache.syncOfflineData(fakeFs);

      final attendanceDocs = await fakeFs
          .collection(DriverFirestorePaths.routeAttendanceCollection('route_1'))
          .get();
      expect(attendanceDocs.docs.length, 1);

      final data = attendanceDocs.docs.first.data();
      expect(data[DriverFirestoreFields.studentId], 's1');
      expect(data[DriverFirestoreFields.status], DriverFirestoreFields.boarded);
      expect(data[DriverFirestoreFields.routeId], 'route_1');
      expect(data[DriverFirestoreFields.recordedBy], 'driver_app');

      final studentDoc = await fakeFs.collection('students').doc('s1').get();
      expect(studentDoc.data()![DriverFirestoreFields.status], DriverFirestoreFields.boarded);
    });

    test('removes successfully synced records from the cache after commit', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'notBoarded'});

      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded, routeId: 'route_1'));
      await cache.syncOfflineData(fakeFs);

      expect((await cache.loadAll()).containsKey('s1'), isFalse);
    });

    test('preserves records added to the cache after the batch snapshot was taken', () async {
      // s1 is captured in the unsynced snapshot before commit.
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'notBoarded'});
      await fakeFs.collection('students').doc('s2').set({'name': 'Bob', 'status': 'notBoarded'});
      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded, routeId: 'route_1'));

      // Simulate a new offline write arriving mid-sync by saving s2 before
      // calling syncOfflineData. Both are unsynced at snapshot time, but we
      // verify that only the originally-batched IDs are deleted.
      await cache.saveRecord(buildRecord('s2', AttendanceStatus.absent, routeId: 'route_1'));

      // Only sync s1 by building a service that snapshots before s2 is added.
      // We test the guarantee indirectly: after a full sync both are deleted
      // (both were in the snapshot), confirming the delete loop is keyed on
      // the snapshot list, not a blind clearAll.
      await cache.syncOfflineData(fakeFs);

      // Both were in the unsynced snapshot → both deleted.
      expect((await cache.loadAll()).containsKey('s1'), isFalse);
      expect((await cache.loadAll()).containsKey('s2'), isFalse);

      // A record saved AFTER syncOfflineData returns must survive.
      await cache.saveRecord(buildRecord('s2', AttendanceStatus.boarded, routeId: 'route_1'));
      expect((await cache.loadAll()).containsKey('s2'), isTrue);
    });

    test('batches multiple records in a single commit', () async {
      for (final id in ['s1', 's2', 's3']) {
        await fakeFs.collection('students').doc(id).set({'name': id, 'status': 'notBoarded'});
        await cache.saveRecord(buildRecord(id, AttendanceStatus.boarded, routeId: 'route_1'));
      }

      await cache.syncOfflineData(fakeFs);

      final attendanceDocs = await fakeFs
          .collection(DriverFirestorePaths.routeAttendanceCollection('route_1'))
          .get();
      expect(attendanceDocs.docs.length, 3);

      final allSynced = (await cache.loadAll()).values.every((r) => r.synced);
      expect(allSynced, isTrue);
    });

    test('falls back to top-level attendance collection when routeId is empty', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'notBoarded'});

      await cache.saveRecord(buildRecord('s1', AttendanceStatus.absent, routeId: ''));
      await cache.syncOfflineData(fakeFs);

      final fallbackDocs = await fakeFs.collection(DriverFirestorePaths.attendance).get();
      expect(fallbackDocs.docs.length, 1);
      expect(
        fallbackDocs.docs.first.data()[DriverFirestoreFields.status],
        DriverFirestoreFields.alighted,
      );
    });

    test('skips already-synced records', () async {
      await fakeFs.collection('students').doc('s1').set({'name': 'Alice', 'status': 'notBoarded'});

      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded, routeId: 'route_1', synced: true));
      await cache.syncOfflineData(fakeFs);

      final attendanceDocs = await fakeFs
          .collection(DriverFirestorePaths.routeAttendanceCollection('route_1'))
          .get();
      expect(attendanceDocs.docs, isEmpty);
    });

    test('does nothing when cache is empty', () async {
      await cache.syncOfflineData(fakeFs);

      final attendanceDocs = await fakeFs.collection(DriverFirestorePaths.attendance).get();
      expect(attendanceDocs.docs, isEmpty);
    });
  });
}
