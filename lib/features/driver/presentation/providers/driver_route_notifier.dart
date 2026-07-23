import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/attendance_cache_service.dart';
import '../../data/models/cached_attendance_record.dart';
import '../../data/repositories/mock_driver_repository.dart';
import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../../../shared/providers/attendance_cache_provider.dart';
import '../../../../shared/providers/connectivity_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class DriverRouteState {
  const DriverRouteState({
    this.stops = const [],
    this.students = const [],
    this.routeProgress = 0.0,
    this.gpsStatus = 'Waiting for route start',
  });

  final List<RouteStop> stops;
  final List<Student> students;
  final double routeProgress;
  final String gpsStatus;

  DriverRouteState copyWith({
    List<RouteStop>? stops,
    List<Student>? students,
    double? routeProgress,
    String? gpsStatus,
  }) {
    return DriverRouteState(
      stops: stops ?? this.stops,
      students: students ?? this.students,
      routeProgress: routeProgress ?? this.routeProgress,
      gpsStatus: gpsStatus ?? this.gpsStatus,
    );
  }
}

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => MockDriverRepository(),
);

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class DriverRouteNotifier extends AsyncNotifier<DriverRouteState> {
  @override
  Future<DriverRouteState> build() async {
    final repo = ref.read(driverRepositoryProvider);
    final cache = ref.read(attendanceCacheProvider);

    final stops = await repo.fetchRouteStops();
    final students = await repo.fetchRouteStudents();

    final cached = cache.loadAll();
    final merged = students.map((s) {
      final record = cached[s.id];
      if (record == null) return s;
      return s.copyWith(status: AttendanceStatus.values[record.statusIndex]);
    }).toList();

    return DriverRouteState(stops: stops, students: merged);
  }

  Future<void> updateAttendance(String studentId, AttendanceStatus status) async {
    final current = state.value;
    if (current == null) return;

    final repo = ref.read(driverRepositoryProvider);
    final cache = ref.read(attendanceCacheProvider);
    final isOnline = ref.read(connectivityProvider).maybeWhen(
          data: (v) => v,
          orElse: () => true,
        );

    final updated = await repo.updateStudentAttendanceStatus(studentId, status);

    if (!isOnline) {
      await cache.saveRecord(CachedAttendanceRecord(
        studentId: updated.id,
        studentName: updated.name,
        stopName: updated.stopName,
        statusIndex: updated.status.index,
        recordedAt: DateTime.now(),
        synced: false,
      ));
    } else {
      await cache.deleteRecord(updated.id);
    }

    final updatedStudents = current.students
        .map((s) => s.id == updated.id ? updated : s)
        .toList();

    final boardedCount =
        updatedStudents.where((s) => s.status == AttendanceStatus.boarded).length;
    final progress =
        updatedStudents.isEmpty ? 0.0 : boardedCount / updatedStudents.length;

    state = AsyncData(current.copyWith(
      students: updatedStudents,
      routeProgress: progress,
      gpsStatus: progress >= 1.0
          ? 'All students marked'
          : 'Route progress ${(progress * 100).round()}%',
    ));
  }
}

final driverRouteProvider =
    AsyncNotifierProvider<DriverRouteNotifier, DriverRouteState>(
  DriverRouteNotifier.new,
);
