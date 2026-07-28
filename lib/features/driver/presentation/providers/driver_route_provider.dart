import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/attendance_cache_provider.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../data/datasources/attendance_cache_service.dart';
import '../../data/models/cached_attendance_record.dart';
import '../../data/repositories/firestore_driver_repository.dart';
import '../../data/repositories/mock_driver_repository.dart';
import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_route_state.dart';

final driverRouteProvider = AsyncNotifierProvider<DriverRouteNotifier, DriverRouteState>(
  DriverRouteNotifier.new,
);

class DriverRouteNotifier extends AsyncNotifier<DriverRouteState> {
  late DriverRepository _repository;

  @override
  FutureOr<DriverRouteState> build() async {
    return _loadRoute();
  }

  Future<DriverRouteState> _loadRoute() async {
    final cacheService = ref.read(attendanceCacheProvider);
    final firestoreRepository = FirestoreDriverRepository();
    _repository = firestoreRepository;

    List<RouteStop> stops = <RouteStop>[];
    List<Student> students = <Student>[];

    try {
      stops = await firestoreRepository.fetchRouteStops();
      students = await firestoreRepository.fetchRouteStudents();
    } catch (_) {
      stops = <RouteStop>[];
      students = <Student>[];
    }

    if (stops.isEmpty || students.isEmpty) {
      final mockRepository = MockDriverRepository();
      _repository = mockRepository;
      try {
        stops = await mockRepository.fetchRouteStops();
        students = await mockRepository.fetchRouteStudents();
      } catch (error) {
        return DriverRouteError(message: error.toString());
      }
    }

    final cached = cacheService.loadAll();
    final merged = students.map((student) {
      final record = cached[student.id];
      if (record == null) return student;
      return student.copyWith(
        status: AttendanceStatus.values[record.statusIndex],
      );
    }).toList();

    final syncedStudents = await _syncPendingCachedAttendance(
      repository: _repository,
      students: merged,
      cacheService: cacheService,
    );

    final boardedCount = syncedStudents
        .where((student) => student.status == AttendanceStatus.boarded)
        .length;
    final progress = syncedStudents.isEmpty
        ? 0.0
        : boardedCount / syncedStudents.length;

    return DriverRouteLoaded(
      stops: stops,
      students: syncedStudents,
      routeProgress: progress,
      gpsStatus: progress >= 1.0
          ? 'All students marked'
          : 'Route progress ${(progress * 100).round()}%',
    );
  }

  Future<void> loadRoute() async {
    state = await AsyncValue.guard(() => _loadRoute());
  }

  Future<void> updateStudentAttendanceStatus({
    required String studentId,
    required AttendanceStatus status,
  }) async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded) return;

    final repository = _repository;
    final cacheService = ref.read(attendanceCacheProvider);
    final isOnline = ref.read(connectivityProvider).maybeWhen(
          data: (value) => value,
          orElse: () => true,
        );

    state = const AsyncLoading<DriverRouteState>();

    late Student updatedStudent;
    try {
      updatedStudent = await repository
          .updateStudentAttendanceStatus(
            studentId,
            status,
            routeId: '',
            busId: '',
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      if (repository is! MockDriverRepository) {
        _repository = MockDriverRepository();
        updatedStudent = await _repository.updateStudentAttendanceStatus(
          studentId,
          status,
          routeId: '',
          busId: '',
        );
      } else {
        state = AsyncError(
          DriverRouteError(message: 'Unable to update attendance.'),
          StackTrace.current,
        );
        return;
      }
    }

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
  }

  Future<List<Student>> _syncPendingCachedAttendance({
    required DriverRepository repository,
    required List<Student> students,
    required AttendanceCacheService cacheService,
  }) async {
    final isOnline = ref.read(connectivityProvider).maybeWhen(
      data: (value) => value,
      orElse: () => true,
    );
    if (!isOnline) return students;

    final cached = cacheService.loadAll();
    if (cached.isEmpty) return students;

    final syncedStudents = List<Student>.from(students);
    for (final record in cached.values) {
      final status = AttendanceStatus.values[record.statusIndex];
      try {
        final updatedStudent = await repository.updateStudentAttendanceStatus(
          record.studentId,
          status,
          routeId: '',
          busId: '',
        );
        final index = syncedStudents.indexWhere((student) => student.id == updatedStudent.id);
        if (index != -1) {
          syncedStudents[index] = updatedStudent;
        }
        await cacheService.deleteRecord(record.studentId);
      } catch (_) {
        continue;
      }
    }

    return syncedStudents;
  }
}
