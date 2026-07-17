import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_route_event.dart';
import 'driver_route_state.dart';

class DriverRouteBloc extends Bloc<DriverRouteEvent, DriverRouteState> {
  DriverRouteBloc({required this.repository}) : super(const DriverRouteInitial()) {
    on<LoadDriverRoute>(_onLoadDriverRoute);
    on<UpdateStudentAttendanceStatus>(_onUpdateStudentAttendanceStatus);
  }

  final DriverRepository repository;

  Future<void> _onLoadDriverRoute(
    LoadDriverRoute event,
    Emitter<DriverRouteState> emit,
  ) async {
    emit(const DriverRouteLoading());
    try {
      final stops = await repository.fetchRouteStops();
      final students = await repository.fetchRouteStudents();
      emit(DriverRouteLoaded(stops: stops, students: students));
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

      final updatedStudents = currentState.students
          .map((student) => student.id == updatedStudent.id
              ? updatedStudent
              : student)
          .toList();

      final boardedCount = updatedStudents
          .where((student) => student.status == AttendanceStatus.boarded)
          .length;
      final totalStudents = updatedStudents.length;
      final progress = totalStudents == 0 ? 0.0 : boardedCount / totalStudents;

      emit(DriverRouteLoaded(
        stops: currentState.stops,
        students: updatedStudents,
        routeProgress: progress,
        gpsStatus: progress >= 1.0
            ? 'All students marked'
            : 'Route progress ${((progress * 100).round())}%',
      ));
    } catch (error) {
      emit(DriverRouteError(message: error.toString()));
    }
  }
}
