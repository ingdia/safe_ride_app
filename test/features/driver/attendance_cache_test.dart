import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_provider.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_state.dart';
import 'package:safe_ride_app/shared/providers/attendance_cache_provider.dart';
import 'package:safe_ride_app/shared/providers/connectivity_provider.dart';

import '../../helpers/fake_attendance_cache_service.dart';

void main() {
  group('FakeAttendanceCacheService', () {
    late FakeAttendanceCacheService cache;

    setUp(() => cache = FakeAttendanceCacheService());

    test('saveRecord stores a record keyed by studentId', () async {
      final record = _makeRecord('s1', AttendanceStatus.boarded);
      await cache.saveRecord(record);
      final loaded = await cache.loadAll();
      expect(loaded['s1'], isNotNull);
      expect(loaded['s1']!.statusIndex, AttendanceStatus.boarded.index);
    });

    test('saveRecord overwrites an existing record for the same studentId', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.absent));
      final loaded = await cache.loadAll();
      expect(loaded['s1']!.statusIndex, AttendanceStatus.absent.index);
    });

    test('deleteRecord removes the entry', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));
      await cache.deleteRecord('s1');
      final loaded = await cache.loadAll();
      expect(loaded.containsKey('s1'), isFalse);
    });

    test('clearAll removes all entries', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));
      await cache.saveRecord(_makeRecord('s2', AttendanceStatus.absent));
      await cache.clearAll();
      final loaded = await cache.loadAll();
      expect(loaded, isEmpty);
    });

    test('loadAll returns unmodifiable map', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));
      final loaded = await cache.loadAll();
      expect(
        () => (loaded as Map<String, CachedAttendanceRecord>)['s2'] =
            _makeRecord('s2', AttendanceStatus.absent),
        throwsUnsupportedError,
      );
    });
  });

  group('DriverRouteProvider — Hive persistence', () {
    late FakeAttendanceCacheService cache;

    setUp(() => cache = FakeAttendanceCacheService());

    ProviderContainer makeContainer({required bool isOnline}) => ProviderContainer(
          overrides: [
            attendanceCacheProvider.overrideWithValue(cache),
            connectivityProvider.overrideWith((ref) => Stream.value(isOnline)),
          ],
        );

    Future<DriverRouteLoaded> load(ProviderContainer container) async {
      final state = await container.read(driverRouteProvider.future);
      return state as DriverRouteLoaded;
    }

    Future<void> update(
      ProviderContainer container,
      String studentId,
      AttendanceStatus status,
    ) async {
      await container.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
            studentId: studentId,
            status: status,
          );
    }

    test('offline update writes record to cache with synced=false', () async {
      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      await load(container);
      await update(container, 's1', AttendanceStatus.boarded);

      final record = (await cache.loadAll())['s1'];
      expect(record, isNotNull);
      expect(record!.statusIndex, AttendanceStatus.boarded.index);
      expect(record.synced, isFalse);
    });

    test('online update removes stale cache entry', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.absent));

      final container = makeContainer(isOnline: true);
      addTearDown(container.dispose);
      await load(container);
      await update(container, 's1', AttendanceStatus.boarded);

      final loaded = await cache.loadAll();
      expect(loaded.containsKey('s1'), isFalse);
    });

    test('cached records are merged onto students on initial load', () async {
      await cache.saveRecord(_makeRecord('s2', AttendanceStatus.absent));

      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      final loaded = await load(container);

      final s2 = loaded.students.firstWhere((s) => s.id == 's2');
      expect(s2.status, AttendanceStatus.absent);
    });

    test('students without a cached record keep their default status', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));

      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      final loaded = await load(container);

      final s3 = loaded.students.firstWhere((s) => s.id == 's3');
      expect(s3.status, AttendanceStatus.notBoarded);
    });
  });
}

CachedAttendanceRecord _makeRecord(String studentId, AttendanceStatus status) =>
    CachedAttendanceRecord(
      studentId: studentId,
      studentName: 'Test Student',
      stopName: 'Oak Street',
      statusIndex: status.index,
      recordedAt: DateTime(2024, 1, 1),
    );
