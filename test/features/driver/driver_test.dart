import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
            connectivityProvider.overrideWith((ref) async* {
              yield isOnline;
            }),
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