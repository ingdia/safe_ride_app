import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/attendance_cache_service.dart';
import '../../data/models/cached_attendance_record.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_route_event.dart';
import 'driver_route_state.dart';

class DriverRouteBloc extends Bloc<DriverRouteEvent, DriverRouteState> {
  DriverRouteBloc({
    required this.repository,
    required this.cacheService,
    required this.isOnline,
  }) : super(const DriverRouteInitial()) {
    on<LoadDriverRoute>(_onLoadDriverRoute);
    on<UpdateStudentAttendanceStatus>(_onUpdateStudentAttendanceStatus);
  }

  final DriverRepository repository;
  final AttendanceCacheService cacheService;
  final bool isOnline;

  Future<void> _onLoadDriverRoute(
    LoadDriverRoute event,
    Emitter<DriverRouteState> emit,
  ) async {
    emit(const DriverRouteLoading());
    try {
      final stops = await repository.fetchRouteStops();
      final students = await repository.fetchRouteStudents();

      // Overlay any cached offline statuses on top of the fetched students.
      final cached = cacheService.loadAll();
      final merged = students.map((s) {
        final record = cached[s.id];
        if (record == null) return s;
        return s.copyWith(
          status: AttendanceStatus.values[record.statusIndex],
        );
      }).toList();

      emit(DriverRouteLoaded(stops: stops, students: merged));
    } catch (error) {
      emit(DriverRouteError(message: error.toString()));
    }
  }

  Future<void> _onUpdateStudentAttendanceStatus(
    UpdateStudentAttendanceStatus event,
    Emitter<DriverRouteState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverRouteLoaded) return;

    try {
      final updatedStudent = await repository.updateStudentAttendanceStatus(
        event.studentId,
        event.status,
      );

      // Persist to Hive when offline so the update survives app restarts.
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
        // Online: remove any stale cached entry for this student.
        await cacheService.deleteRecord(updatedStudent.id);
      }

      final updatedStudents = currentState.students
          .map((s) => s.id == updatedStudent.id ? updatedStudent : s)
          .toList();

      final boardedCount = updatedStudents
          .where((s) => s.status == AttendanceStatus.boarded)
          .length;
      final progress =
          updatedStudents.isEmpty ? 0.0 : boardedCount / updatedStudents.length;

      emit(DriverRouteLoaded(
        stops: currentState.stops,
        students: updatedStudents,
        routeProgress: progress,
        gpsStatus: progress >= 1.0
            ? 'All students marked'
            : 'Route progress ${(progress * 100).round()}%',
      ));
    } catch (error) {
      emit(DriverRouteError(message: error.toString()));
    }
  }
}
