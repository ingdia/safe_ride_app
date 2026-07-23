import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/attendance_cache_provider.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../data/models/cached_attendance_record.dart';
import '../../data/repositories/mock_driver_repository.dart';
import '../../domain/models/student.dart';
import 'driver_route_state.dart';

final driverRouteProvider = AsyncNotifierProvider<DriverRouteNotifier, DriverRouteState>(
  DriverRouteNotifier.new,
);

class DriverRouteNotifier extends AsyncNotifier<DriverRouteState> {
  @override
  FutureOr<DriverRouteState> build() async {
    return _loadRoute();
  }

  Future<DriverRouteState> _loadRoute() async {
    final repository = MockDriverRepository();
    final cacheService = ref.read(attendanceCacheProvider);
    ref.watch(connectivityProvider).maybeWhen(
      data: (value) => value,
      orElse: () => true,
    );

    state = const AsyncLoading<DriverRouteState>();
    try {
      final stops = await repository.fetchRouteStops();
      final students = await repository.fetchRouteStudents();

      final cached = cacheService.loadAll();
      final merged = students.map((student) {
        final record = cached[student.id];
        if (record == null) return student;
        return student.copyWith(
          status: AttendanceStatus.values[record.statusIndex],
        );
      }).toList();

      return DriverRouteLoaded(stops: stops, students: merged);
    } catch (error) {
      return DriverRouteError(message: error.toString());
    }
  }

  Future<void> loadRoute() async {
    state = const AsyncLoading<DriverRouteState>();
    state = await AsyncValue.guard(() => _loadRoute());
  }

  Future<void> updateStudentAttendanceStatus({
    required String studentId,
    required AttendanceStatus status,
  }) async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded) return;

    final repository = MockDriverRepository();
    final cacheService = ref.read(attendanceCacheProvider);
    final isOnline = ref.watch(connectivityProvider).maybeWhen(
      data: (value) => value,
      orElse: () => true,
    );

    state = const AsyncLoading<DriverRouteState>();

    try {
      final updatedStudent = await repository.updateStudentAttendanceStatus(
        studentId,
        status,
      );

      if (!isOnline) {
        await cacheService.saveRecord(
          CachedAttendanceRecord(
            studentId: updatedStudent.id,
            studentName: updatedStudent.name,
            stopName: updatedStudent.stopName,
            statusIndex: updatedStudent.status.index,
            recordedAt: DateTime.now(),
            synced: false,
          ),
        );
      } else {
        await cacheService.deleteRecord(updatedStudent.id);
      }

      final updatedStudents = currentState.students
          .map((student) => student.id == updatedStudent.id ? updatedStudent : student)
          .toList();

      final boardedCount = updatedStudents
          .where((student) => student.status == AttendanceStatus.boarded)
          .length;
      final progress = updatedStudents.isEmpty
          ? 0.0
          : boardedCount / updatedStudents.length;

      state = AsyncData(
        DriverRouteLoaded(
          stops: currentState.stops,
          students: updatedStudents,
          routeProgress: progress,
          gpsStatus: progress >= 1.0
              ? 'All students marked'
              : 'Route progress ${(progress * 100).round()}%',
        ),
      );
    } catch (error) {
      state = AsyncError(
        DriverRouteError(message: error.toString()),
        StackTrace.current,
      );
    }
  }
}
