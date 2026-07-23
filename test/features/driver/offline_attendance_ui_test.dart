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
  late FakeAttendanceCacheService cache;

  setUp(() => cache = FakeAttendanceCacheService());

  ProviderContainer makeContainer({required bool isOnline}) => ProviderContainer(
        overrides: [
          attendanceCacheProvider.overrideWithValue(cache),
          connectivityProvider.overrideWith((ref) => Stream.value(isOnline)),
        ],
      );

  Future<DriverRouteState> loadAndWait(ProviderContainer container) async {
    return await container.read(driverRouteProvider.future);
  }

  Future<void> updateAndWait(
    ProviderContainer container,
    String studentId,
    AttendanceStatus status,
  ) async {
    await container.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
          studentId: studentId,
          status: status,
        );
  }

  group('Offline attendance UI state', () {
    test('emits DriverRouteLoaded on load', () async {
      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);

      final state = await loadAndWait(container);
      expect(state, isA<DriverRouteLoaded>());
    });

    test('offline mark updates student status in state', () async {
      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      await loadAndWait(container);
      await updateAndWait(container, 's1', AttendanceStatus.boarded);

      final loaded = container.read(driverRouteProvider).value as DriverRouteLoaded;
      final s1 = loaded.students.firstWhere((s) => s.id == 's1');
      expect(s1.status, AttendanceStatus.boarded);
    });

    test('offline mark updates routeProgress in state', () async {
      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      await loadAndWait(container);
      await updateAndWait(container, 's1', AttendanceStatus.boarded);

      final loaded = container.read(driverRouteProvider).value as DriverRouteLoaded;
      expect(loaded.routeProgress, greaterThan(0.0));
    });

    test('gpsStatus reflects offline progress correctly', () async {
      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      await loadAndWait(container);
      await updateAndWait(container, 's1', AttendanceStatus.boarded);

      final loaded = container.read(driverRouteProvider).value as DriverRouteLoaded;
      expect(loaded.gpsStatus, contains('Route progress'));
    });

    test('marking all students offline sets gpsStatus to all-marked message', () async {
      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      await loadAndWait(container);

      for (final id in ['s1', 's2', 's3', 's4', 's5']) {
        await updateAndWait(container, id, AttendanceStatus.boarded);
      }

      final loaded = container.read(driverRouteProvider).value as DriverRouteLoaded;
      expect(loaded.routeProgress, 1.0);
      expect(loaded.gpsStatus, 'All students marked');
    });

    test('cached statuses are reflected in state on fresh load', () async {
      await cache.saveRecord(CachedAttendanceRecord(
        studentId: 's3',
        studentName: 'Aline Mukamana',
        stopName: 'Oak Street',
        statusIndex: AttendanceStatus.absent.index,
        recordedAt: DateTime(2024, 1, 1),
        synced: false,
      ));

      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      final state = await loadAndWait(container);

      final loaded = state as DriverRouteLoaded;
      final s3 = loaded.students.firstWhere((s) => s.id == 's3');
      expect(s3.status, AttendanceStatus.absent);
    });

    test('multiple offline updates accumulate correctly in cache', () async {
      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      await loadAndWait(container);

      await updateAndWait(container, 's1', AttendanceStatus.boarded);
      await updateAndWait(container, 's2', AttendanceStatus.absent);

      final loadedCache = await cache.loadAll();
      expect(loadedCache.length, 2);
      expect(loadedCache['s1']!.statusIndex, AttendanceStatus.boarded.index);
      expect(loadedCache['s2']!.statusIndex, AttendanceStatus.absent.index);
    });
  });
}
