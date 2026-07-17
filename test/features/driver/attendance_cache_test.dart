import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/driver/data/models/cached_attendance_record.dart';
import 'package:safe_ride_app/features/driver/data/repositories/mock_driver_repository.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_bloc.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_event.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_state.dart';

import '../../helpers/fake_attendance_cache_service.dart';

void main() {
  group('FakeAttendanceCacheService', () {
    late FakeAttendanceCacheService cache;

    setUp(() => cache = FakeAttendanceCacheService());

    test('saveRecord stores a record keyed by studentId', () async {
      final record = _makeRecord('s1', AttendanceStatus.boarded);
      await cache.saveRecord(record);
      expect(cache.loadAll()['s1'], isNotNull);
      expect(cache.loadAll()['s1']!.statusIndex, AttendanceStatus.boarded.index);
    });

    test('saveRecord overwrites an existing record for the same studentId', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.absent));
      expect(cache.loadAll()['s1']!.statusIndex, AttendanceStatus.absent.index);
    });

    test('deleteRecord removes the entry', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));
      await cache.deleteRecord('s1');
      expect(cache.loadAll().containsKey('s1'), isFalse);
    });

    test('clearAll removes all entries', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));
      await cache.saveRecord(_makeRecord('s2', AttendanceStatus.absent));
      await cache.clearAll();
      expect(cache.loadAll(), isEmpty);
    });

    test('loadAll returns unmodifiable map', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));
      expect(
        () => (cache.loadAll() as Map<String, CachedAttendanceRecord>)['s2'] =
            _makeRecord('s2', AttendanceStatus.absent),
        throwsUnsupportedError,
      );
    });
  });

  group('DriverRouteBloc — Hive persistence', () {
    late FakeAttendanceCacheService cache;

    setUp(() => cache = FakeAttendanceCacheService());

    DriverRouteBloc makeBloc({required bool isOnline}) => DriverRouteBloc(
          repository: MockDriverRepository(),
          cacheService: cache,
          isOnline: isOnline,
        );

    Future<void> load(DriverRouteBloc bloc) async {
      bloc.add(const LoadDriverRoute());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    Future<void> update(
      DriverRouteBloc bloc,
      String studentId,
      AttendanceStatus status,
    ) async {
      bloc.add(UpdateStudentAttendanceStatus(studentId: studentId, status: status));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    test('offline update writes record to cache with synced=false', () async {
      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await load(bloc);
      await update(bloc, 's1', AttendanceStatus.boarded);

      final record = cache.loadAll()['s1'];
      expect(record, isNotNull);
      expect(record!.statusIndex, AttendanceStatus.boarded.index);
      expect(record.synced, isFalse);
    });

    test('online update removes stale cache entry', () async {
      // Pre-seed a cached record as if it was saved while offline.
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.absent));

      final bloc = makeBloc(isOnline: true);
      addTearDown(bloc.close);
      await load(bloc);
      await update(bloc, 's1', AttendanceStatus.boarded);

      expect(cache.loadAll().containsKey('s1'), isFalse);
    });

    test('cached records are merged onto students on LoadDriverRoute', () async {
      // Simulate a previously saved offline record.
      await cache.saveRecord(_makeRecord('s2', AttendanceStatus.absent));

      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await load(bloc);

      final loaded = bloc.state as DriverRouteLoaded;
      final s2 = loaded.students.firstWhere((s) => s.id == 's2');
      expect(s2.status, AttendanceStatus.absent);
    });

    test('students without a cached record keep their default status', () async {
      await cache.saveRecord(_makeRecord('s1', AttendanceStatus.boarded));

      final bloc = makeBloc(isOnline: false);
      addTearDown(bloc.close);
      await load(bloc);

      final loaded = bloc.state as DriverRouteLoaded;
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
