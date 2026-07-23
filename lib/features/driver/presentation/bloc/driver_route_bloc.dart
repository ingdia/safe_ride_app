import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/attendance_cache_service.dart';
import '../../data/models/cached_attendance_record.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_route_event.dart';
import 'driver_route_state.dart';

class DriverRouteBloc extends Bloc<DriverRouteEvent, DriverRouteState> {
  DriverRouteBloc({
    required DriverRepository repository,
    required AttendanceCacheService cacheService,
    required bool isOnline,
  })  : _repository = repository,
        _cacheService = cacheService,
        _isOnline = isOnline,
        super(const DriverRouteInitial()) {
    on<LoadDriverRoute>(_onLoad);
    on<UpdateStudentAttendanceStatus>(_onUpdateStatus);
  }

  final DriverRepository _repository;
  final AttendanceCacheService _cacheService;
  final bool _isOnline;

  Future<void> _onLoad(LoadDriverRoute event, Emitter<DriverRouteState> emit) async {
    emit(const DriverRouteLoading());
    try {
      final stops = await _repository.fetchRouteStops();
      final students = await _repository.fetchRouteStudents();

      final cached = _cacheService.loadAll();
      final merged = students.map((s) {
        final record = cached[s.id];
        if (record == null) return s;
        return s.copyWith(status: AttendanceStatus.values[record.statusIndex]);
      }).toList();

      emit(DriverRouteLoaded(stops: stops, students: merged));
    } catch (e) {
      emit(DriverRouteError(message: e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateStudentAttendanceStatus event,
    Emitter<DriverRouteState> emit,
  ) async {
    final current = state;
    if (current is! DriverRouteLoaded) return;

    try {
      final updated = await _repository.updateStudentAttendanceStatus(
        event.studentId,
        event.status,
      );

      if (!_isOnline) {
        await _cacheService.saveRecord(CachedAttendanceRecord(
          studentId: updated.id,
          studentName: updated.name,
          stopName: updated.stopName,
          statusIndex: updated.status.index,
          recordedAt: DateTime.now(),
          synced: false,
        ));
      } else {
        await _cacheService.deleteRecord(updated.id);
      }

      final updatedStudents = current.students
          .map((s) => s.id == updated.id ? updated : s)
          .toList();

      final boardedCount =
          updatedStudents.where((s) => s.status == AttendanceStatus.boarded).length;
      final progress =
          updatedStudents.isEmpty ? 0.0 : boardedCount / updatedStudents.length;

      emit(DriverRouteLoaded(
        stops: current.stops,
        students: updatedStudents,
        routeProgress: progress,
        gpsStatus: progress >= 1.0
            ? 'All students marked'
            : 'Route progress ${(progress * 100).round()}%',
      ));
    } catch (e) {
      emit(DriverRouteError(message: e.toString()));
    }
  }
}
