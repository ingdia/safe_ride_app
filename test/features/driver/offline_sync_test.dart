/// Tests for offline caching and sync logic.
///
/// Covers three scenarios:
///   1. Records save locally when offline.
///   2. Sync pushes correctly when online.
///   3. Cache clears only on success (failed records are retained for retry).
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:safe_ride_app/core/firebase/firebase_collections.dart';
import 'package:safe_ride_app/features/driver/data/datasources/attendance_cache_service.dart';
import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';
import 'package:safe_ride_app/features/driver/data/repositories/mock_driver_repository.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_provider.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_state.dart';
import 'package:safe_ride_app/shared/providers/attendance_cache_provider.dart';
import 'package:safe_ride_app/shared/providers/connectivity_provider.dart';

import '../../helpers/fake_attendance_cache_service.dart';
import '../../helpers/fake_record_builder.dart';

// ---------------------------------------------------------------------------
// Provider helpers (use FakeAttendanceCacheService — no Hive needed)
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({
  required bool isOnline,
  required FakeAttendanceCacheService cache,
}) =>
    ProviderContainer(
      overrides: [
        attendanceCacheProvider.overrideWithValue(cache),
        connectivityProvider.overrideWithValue(AsyncData(isOnline)),
        driverRepositoryProvider.overrideWithValue(MockDriverRepository()),
      ],
    );

Future<DriverRouteLoaded> _load(ProviderContainer c) async =>
    (await c.read(driverRouteProvider.future)) as DriverRouteLoaded;

Future<void> _mark(
  ProviderContainer c,
  String studentId,
  AttendanceStatus status,
) =>
    c.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
          studentId: studentId,
          status: status,
        );

// ---------------------------------------------------------------------------
// _PartialFailCache — simulates one record always failing during sync
// ---------------------------------------------------------------------------

class _PartialFailCache extends FakeAttendanceCacheService {
  _PartialFailCache(this.failStudentId, this._fakeFs);

  final String failStudentId;
  final FakeFirebaseFirestore _fakeFs;

  @override
  Future<void> syncOfflineData([firestore]) async {
    final snapshot = Map<String, CachedAttendanceRecord>.from(
      await loadAll(),
    )..removeWhere((_, r) => r.synced);

    for (final entry in snapshot.entries) {
      if (entry.key == failStudentId) continue; // simulate write failure

      final record = entry.value;
      final statusValue =
          record.statusIndex == AttendanceStatus.boarded.index ? 'boarded' : 'alighted';

      if (record.routeId.isNotEmpty) {
        final routeDoc =
            await _fakeFs.collection(FirebaseCollections.routes).doc(record.routeId).get();
        final busId = routeDoc.data()?['busId'] as String?;
        if (busId != null && busId.isNotEmpty) {
          final tripQuery = await _fakeFs
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

      await _fakeFs
          .collection(FirebaseCollections.students)
          .doc(record.studentId)
          .set({'attendanceStatus': statusValue}, SetOptions(merge: true));
      await deleteRecord(record.studentId);
    }
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── 1. Records save locally when offline ──────────────────────────────────
  group('offline — records save locally', () {
    late FakeAttendanceCacheService cache;

    setUp(() => cache = FakeAttendanceCacheService());

    test('marking boarded while offline writes record with synced=false', () async {
      final container = _makeContainer(isOnline: false, cache: cache);
      addTearDown(container.dispose);

      await _load(container);
      await _mark(container, 's1', AttendanceStatus.boarded);

      final record = (await cache.loadAll())['s1'];
      expect(record, isNotNull);
      expect(record!.statusIndex, AttendanceStatus.boarded.index);
      expect(record.synced, isFalse);
    });

    test('marking absent while offline writes record with synced=false', () async {
      final container = _makeContainer(isOnline: false, cache: cache);
      addTearDown(container.dispose);

      await _load(container);
      await _mark(container, 's2', AttendanceStatus.absent);

      final record = (await cache.loadAll())['s2'];
      expect(record, isNotNull);
      expect(record!.statusIndex, AttendanceStatus.absent.index);
      expect(record.synced, isFalse);
    });

    test('marking notBoarded while offline removes any stale cached record', () async {
      await cache.saveRecord(buildRecord('s1', AttendanceStatus.boarded));

      final container = _makeContainer(isOnline: false, cache: cache);
      addTearDown(container.dispose);

      await _load(container);
      await _mark(container, 's1', AttendanceStatus.notBoarded);

      expect((await cache.loadAll()).containsKey('s1'), isFalse);
    });

    test('multiple offline marks accumulate in cache', () async {
      final container = _makeContainer(isOnline: false, cache: cache);
      addTearDown(container.dispose);

      await _load(container);
      await _mark(container, 's1', AttendanceStatus.boarded);
      await _mark(container, 's2', AttendanceStatus.absent);

      final all = await cache.loadAll();
      expect(all.containsKey('s1'), isTrue);
      expect(all.containsKey('s2'), isTrue);
    });
  });

  // ── 2. Sync pushes correctly when online ──────────────────────────────────
  group('online — sync pushes to Firestore', () {
    late Directory tempDir;
    late FakeFirebaseFirestore fakeFs;
    late AttendanceCacheService realCache;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_offline_sync_test_');
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
      fakeFs = FakeFirebaseFirestore();
      realCache = AttendanceCacheService();
    });

    tearDown(() => Hive.deleteBoxFromDisk('offline_attendance'));

    test('syncOfflineData sets the trip studentEvents entry and attendanceStatus', () async {
      await fakeFs
          .collection('students')
          .doc('s1')
          .set({'name': 'Alice', 'status': 'approved'});
      // schoolId seeded on the route doc — AttendanceCacheService.syncOfflineData
      // filters the trips query by schoolId too, since the `trips` security
      // rule gates reads on it and a query missing that filter is rejected.
      await fakeFs
          .collection(FirebaseCollections.routes)
          .doc('r1')
          .set({'busId': 'bus_1', 'schoolId': 'school_1'});
      final tripRef = await fakeFs.collection(FirebaseCollections.trips).add({
        'busId': 'bus_1',
        'schoolId': 'school_1',
        'routeId': 'r1',
        'status': 'inProgress',
        'studentEvents': <String, dynamic>{},
      });

      await realCache.saveRecord(
          buildRecord('s1', AttendanceStatus.boarded, routeId: 'r1'));
      await realCache.syncOfflineData(fakeFs);

      final tripDoc = await fakeFs.collection(FirebaseCollections.trips).doc(tripRef.id).get();
      expect(tripDoc.data()!['studentEvents'], {'s1': 'boarded'});

      final studentDoc =
          await fakeFs.collection('students').doc('s1').get();
      expect(studentDoc.data()!['attendanceStatus'], 'boarded');
    });

    test('synced record is removed from cache after successful push', () async {
      await fakeFs
          .collection('students')
          .doc('s1')
          .set({'name': 'Alice', 'status': 'approved'});

      await realCache.saveRecord(
          buildRecord('s1', AttendanceStatus.boarded, routeId: 'r1'));
      await realCache.syncOfflineData(fakeFs);

      expect((await realCache.loadAll()).containsKey('s1'), isFalse);
    });

    test('online initial load (provider) triggers sync and clears cache', () async {
      final cache = FakeAttendanceCacheService();
      await cache.saveRecord(buildRecord('s2', AttendanceStatus.absent));

      final container = _makeContainer(isOnline: true, cache: cache);
      addTearDown(container.dispose);

      final loaded = await _load(container);

      expect((await cache.loadAll()).isEmpty, isTrue);
      expect(
        loaded.students.firstWhere((s) => s.id == 's2').status,
        AttendanceStatus.absent,
      );
    });

    test('online mark removes stale cache entry immediately', () async {
      final cache = FakeAttendanceCacheService();
      await cache.saveRecord(buildRecord('s1', AttendanceStatus.absent));

      final container = _makeContainer(isOnline: true, cache: cache);
      addTearDown(container.dispose);

      await _load(container);
      await _mark(container, 's1', AttendanceStatus.boarded);

      expect((await cache.loadAll()).containsKey('s1'), isFalse);
    });

    test('reconnect triggers sync and clears pending offline records', () async {
      final cache = FakeAttendanceCacheService();
      final container = _makeContainer(isOnline: false, cache: cache);
      addTearDown(container.dispose);

      await _load(container);
      await _mark(container, 's1', AttendanceStatus.boarded);
      expect((await cache.loadAll()).containsKey('s1'), isTrue);

      container.updateOverrides([
        attendanceCacheProvider.overrideWithValue(cache),
        connectivityProvider.overrideWithValue(const AsyncData(true)),
        driverRepositoryProvider.overrideWithValue(MockDriverRepository()),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect((await cache.loadAll()).containsKey('s1'), isFalse);
    });
  });

  // ── 3. Cache clears only on success ───────────────────────────────────────
  group('partial failure — cache clears only on success', () {
    late FakeFirebaseFirestore fakeFs;

    setUp(() => fakeFs = FakeFirebaseFirestore());

    test('successful records are removed; failed record is retained', () async {
      final cache = _PartialFailCache('s2', fakeFs);
      for (final id in ['s1', 's2', 's3']) {
        await cache.saveRecord(
            buildRecord(id, AttendanceStatus.boarded, routeId: 'r1'));
      }

      await cache.syncOfflineData();

      final remaining = await cache.loadAll();
      expect(remaining.containsKey('s1'), isFalse);
      expect(remaining.containsKey('s2'), isTrue); // failed — kept for retry
      expect(remaining.containsKey('s3'), isFalse);
    });

    test('failed record is retried and cleared on next successful sync', () async {
      final cache = _PartialFailCache('s2', fakeFs);
      await cache.saveRecord(
          buildRecord('s2', AttendanceStatus.boarded, routeId: 'r1'));

      // First sync — s2 fails, stays in cache.
      await cache.syncOfflineData();
      expect((await cache.loadAll()).containsKey('s2'), isTrue);

      // Second sync — manually clear the failed record (simulating success).
      await cache.deleteRecord('s2');
      expect((await cache.loadAll()).containsKey('s2'), isFalse);
    });

    test('already-synced records are skipped during sync', () async {
      final cache = _PartialFailCache('none', fakeFs);
      await cache.saveRecord(
          buildRecord('s1', AttendanceStatus.boarded, routeId: 'r1', synced: true));

      await cache.syncOfflineData();

      final docs = await fakeFs.collection(FirebaseCollections.trips).get();
      expect(docs.docs, isEmpty);
      // synced record untouched in cache (not deleted by sync)
      expect((await cache.loadAll()).containsKey('s1'), isTrue);
    });

    test('empty cache produces no Firestore writes', () async {
      final cache = FakeAttendanceCacheService();
      await cache.syncOfflineData();

      final docs = await fakeFs.collection(FirebaseCollections.trips).get();
      expect(docs.docs, isEmpty);
    });
  });
}
