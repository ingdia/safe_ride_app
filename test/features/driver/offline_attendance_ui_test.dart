import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';
import 'package:safe_ride_app/features/driver/data/repositories/mock_driver_repository.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_bloc.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_event.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_state.dart';

import '../../helpers/fake_attendance_cache_service.dart';

void main() {
  late FakeAttendanceCacheService cache;

  setUp(() => cache = FakeAttendanceCacheService());

  DriverRouteBloc makeBloc({required bool isOnline}) => DriverRouteBloc(
        repository: MockDriverRepository(),
        cacheService: cache,
        isOnline: isOnline,
      );

  Future<void> loadAndWait(DriverRouteBloc bloc) async {
    bloc.add(const LoadDriverRoute());
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Future<void> updateAndWait(
    DriverRouteBloc bloc,
    String studentId,
    AttendanceStatus status,
  ) async {
    bloc.add(UpdateStudentAttendanceStatus(studentId: studentId, status: status));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  group('Offline attendance UI state', () {
    test('emits DriverRouteLoading then DriverRouteLoaded on load', () async {
      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);

      final states = <DriverRouteState>[];
      final sub = bloc.stream.listen(states.add);
      await loadAndWait(bloc);
      await sub.cancel();

      expect(states[0], isA<DriverRouteLoading>());
      expect(states[1], isA<DriverRouteLoaded>());
    });

    test('offline mark updates student status in emitted state', () async {
      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await loadAndWait(bloc);
      await updateAndWait(bloc, 's1', AttendanceStatus.boarded);

      final loaded = bloc.state as DriverRouteLoaded;
      final s1 = loaded.students.firstWhere((s) => s.id == 's1');
      expect(s1.status, AttendanceStatus.boarded);
    });

    test('offline mark updates routeProgress in emitted state', () async {
      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await loadAndWait(bloc);
      await updateAndWait(bloc, 's1', AttendanceStatus.boarded);

      final loaded = bloc.state as DriverRouteLoaded;
      expect(loaded.routeProgress, greaterThan(0.0));
    });

    test('gpsStatus reflects offline progress correctly', () async {
      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await loadAndWait(bloc);
      await updateAndWait(bloc, 's1', AttendanceStatus.boarded);

      final loaded = bloc.state as DriverRouteLoaded;
      expect(loaded.gpsStatus, contains('Route progress'));
    });

    test('marking all students offline sets gpsStatus to all-marked message', () async {
      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await loadAndWait(bloc);

      for (final id in ['s1', 's2', 's3', 's4', 's5']) {
        await updateAndWait(bloc, id, AttendanceStatus.boarded);
      }

      final loaded = bloc.state as DriverRouteLoaded;
      expect(loaded.routeProgress, 1.0);
      expect(loaded.gpsStatus, 'All students marked');
    });

    test('cached statuses are reflected in UI state on fresh bloc load', () async {
      // Simulate data saved during a previous offline session.
      await cache.saveRecord(CachedAttendanceRecord(
        studentId: 's3',
        studentName: 'Aline Mukamana',
        stopName: 'Oak Street',
        statusIndex: AttendanceStatus.absent.index,
        recordedAt: DateTime(2024, 1, 1),
        synced: false,
      ));

      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await loadAndWait(bloc);

      final loaded = bloc.state as DriverRouteLoaded;
      final s3 = loaded.students.firstWhere((s) => s.id == 's3');
      expect(s3.status, AttendanceStatus.absent);
    });

    test('multiple offline updates accumulate correctly in cache', () async {
      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await loadAndWait(bloc);

      await updateAndWait(bloc, 's1', AttendanceStatus.boarded);
      await updateAndWait(bloc, 's2', AttendanceStatus.absent);

      expect(cache.loadAll().length, 2);
      expect(cache.loadAll()['s1']!.statusIndex, AttendanceStatus.boarded.index);
      expect(cache.loadAll()['s2']!.statusIndex, AttendanceStatus.absent.index);
    });
  });
}
