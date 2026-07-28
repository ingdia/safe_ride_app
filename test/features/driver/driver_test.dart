import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';
import 'package:safe_ride_app/features/driver/data/repositories/mock_driver_repository.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_provider.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_state.dart';
import 'package:safe_ride_app/shared/providers/attendance_cache_provider.dart';
import 'package:safe_ride_app/shared/providers/connectivity_provider.dart';

import '../../helpers/fake_attendance_cache_service.dart';

void main() {
  group('DriverRouteProvider', () {
    late FakeAttendanceCacheService cache;

    setUp(() => cache = FakeAttendanceCacheService());

    ProviderContainer makeContainer({required bool isOnline}) => ProviderContainer(
          overrides: [
            attendanceCacheProvider.overrideWithValue(cache),
            connectivityProvider.overrideWith((ref) => Stream.value(isOnline)),
            driverRepositoryProvider.overrideWithValue(MockDriverRepository()),
          ],
        );

    test('load event returns stops and students', () async {
      final container = makeContainer(isOnline: true);
      addTearDown(container.dispose);

      final state = await container.read(driverRouteProvider.future);
      expect(state, isA<DriverRouteLoaded>());

      final loaded = state as DriverRouteLoaded;
      expect(loaded.stops, isNotEmpty);
      expect(loaded.students, isNotEmpty);
      expect(loaded.stops.first.name, 'Oak Street');
      expect(loaded.students.first.name, 'Emma Johnson');
    });

    test('status updates change student attendance', () async {
      final container = makeContainer(isOnline: true);
      addTearDown(container.dispose);

      await container.read(driverRouteProvider.future);
      await container.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
            studentId: 's1',
            status: AttendanceStatus.boarded,
          );

      final state = container.read(driverRouteProvider);
      expect(state.value, isA<DriverRouteLoaded>());

      final loaded = state.value as DriverRouteLoaded;
      final student = loaded.students.firstWhere((item) => item.id == 's1');
      expect(student.status, AttendanceStatus.boarded);
    });

    test('bus location updates update gps status', () async {
      final container = makeContainer(isOnline: true);
      addTearDown(container.dispose);

      await container.read(driverRouteProvider.future);
      await container.read(driverRouteProvider.notifier).updateBusLocation(
            latitude: -1.9445,
            longitude: 30.0612,
          );

      final state = container.read(driverRouteProvider);
      expect(state.value, isA<DriverRouteLoaded>());

      final loaded = state.value as DriverRouteLoaded;
      expect(loaded.gpsStatus, contains('GPS live'));
      expect(loaded.lastGpsUpdateAt, isNotNull);
    });

    test('online initial load syncs cached attendance and clears cache', () async {
      await cache.saveRecord(_makeRecord('s2', AttendanceStatus.absent));

      final container = makeContainer(isOnline: true);
      addTearDown(container.dispose);

      final loaded = await container.read(driverRouteProvider.future) as DriverRouteLoaded;
      print('loaded statuses: ${loaded.students.map((s) => '${s.id}:${s.status}').join(', ')}');
      expect(loaded.students.firstWhere((s) => s.id == 's2').status, AttendanceStatus.absent);
      expect(cache.loadAll().isEmpty, isTrue);
    });

    test('offline notBoarded clears stale cached attendance record', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));

      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);
      await container.read(driverRouteProvider.future);
      await container.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
            studentId: 's1',
            status: AttendanceStatus.notBoarded,
          );

      expect(cache.loadAll().containsKey('s1'), isFalse);
    });

    test('reconnect syncs cached attendance when connectivity returns online', () async {
      final connectivityStream = StreamController<bool>();
      final container = ProviderContainer(
        overrides: [
          attendanceCacheProvider.overrideWithValue(cache),
          connectivityProvider.overrideWith((ref) async* {
            yield false;
            yield* connectivityStream.stream;
          }),
          driverRepositoryProvider.overrideWithValue(MockDriverRepository()),
        ],
      );
      addTearDown(() {
        connectivityStream.close();
        container.dispose();
      });

      final loadFuture = container.read(driverRouteProvider.future);
      await loadFuture;

      await container.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
            studentId: 's1',
            status: AttendanceStatus.boarded,
          );
      expect(cache.loadAll().containsKey('s1'), isTrue);

      final onlineCompleter = Completer<void>();
      container.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
        if (next.when(data: (value) => value == true, loading: () => false, error: (_, __) => false)) {
          if (!onlineCompleter.isCompleted) {
            onlineCompleter.complete();
          }
        }
      });

      connectivityStream.add(true);
      await onlineCompleter.future;
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(cache.loadAll().containsKey('s1'), isFalse);
      final loaded = container.read(driverRouteProvider).value as DriverRouteLoaded;
      expect(loaded.students.firstWhere((s) => s.id == 's1').status, AttendanceStatus.boarded);
    });
  });

  group('MockDriverRepository', () {
    test('returns expected sample data', () async {
      final repository = MockDriverRepository();

      final stops = await repository.fetchRouteStops();
      final students = await repository.fetchRouteStudents();

      expect(stops.length, 5);
      expect(stops.first.name, 'Oak Street');
      expect(stops.first.studentCount, 3);
      expect(students.length, 5);
      expect(students.first.id, 's1');
      expect(students.first.stopName, 'Oak Street');

      final updatedStudent = await repository.updateStudentAttendanceStatus(
        's2',
        AttendanceStatus.absent,
      );

      expect(updatedStudent.status, AttendanceStatus.absent);
    });
  });
}

CachedAttendanceRecord _makeRecord(String studentId, AttendanceStatus status) => CachedAttendanceRecord(
      studentId: studentId,
      studentName: 'Test Student',
      stopName: 'Oak Street',
      statusIndex: status.index,
      recordedAt: DateTime(2024, 1, 1),
    );
