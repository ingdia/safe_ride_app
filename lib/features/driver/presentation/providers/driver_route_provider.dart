import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/attendance_cache_provider.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../data/datasources/attendance_cache_service.dart';
import '../../data/datasources/driver_stream_service.dart';
import '../../data/models/cached_attendance_record.dart';
import '../../data/models/driver_alert.dart';
import '../../data/models/route_data.dart';
import '../../data/repositories/firestore_driver_repository.dart';
import '../../data/repositories/mock_driver_repository.dart';
import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_route_state.dart';

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => FirestoreDriverRepository(),
);

/// Provides the [DriverStreamService] instance used for live Firestore streams.
final driverStreamServiceProvider = Provider<DriverStreamService>(
  (ref) => DriverStreamService(),
);

/// Exposes a live [Stream] of [RouteData] for the given [routeId].
///
/// Emits `null` when the route document does not exist in Firestore.
final routeDataStreamProvider =
    StreamProvider.family<RouteData?, String>((ref, routeId) {
  return ref.watch(driverStreamServiceProvider).routeDataStream(routeId);
});

/// Exposes a live [Stream] of Admin-sent [DriverAlert]s for the given [routeId].
///
/// Ordered by `timestamp` descending. Emits an empty list when no alerts exist.
final driverAlertsStreamProvider =
    StreamProvider.family<List<DriverAlert>, String>((ref, routeId) {
  return ref.watch(driverStreamServiceProvider).alertsStream(routeId);
});
final driverRouteProvider = AsyncNotifierProvider<DriverRouteNotifier, DriverRouteState>(
  DriverRouteNotifier.new,
);

/// Riverpod [AsyncNotifier] that owns the driver's active-route state.
///
/// ## Attendance update flow
///
/// [updateStudentAttendanceStatus] decides the write strategy based on
/// connectivity:
///
/// - **Online:** calls [DriverRepository.updateStudentAttendanceStatus] with
///   the resolved [_routeId] / [_busId], then removes any stale cache entry.
/// - **Offline:** delegates to [MockDriverRepository] for an optimistic local
///   update and persists a [CachedAttendanceRecord] (synced = false) via
///   [AttendanceCacheService].
/// - **notBoarded:** resets the student locally and deletes any cached record
///   without touching Firestore.
///
/// When connectivity is restored, [_syncCachedAttendanceIfOnline] replays
/// every pending cache record against Firestore and clears the cache.
///
/// ## GPS update flow
///
/// [updateBusLocation] forwards coordinates to
/// [DriverRepository.updateBusLocation] and, on success, stamps
/// [DriverRouteLoaded.lastGpsUpdateAt] so the UI can display a live
/// "updated just now" indicator.
class DriverRouteNotifier extends AsyncNotifier<DriverRouteState> {
  late DriverRepository _repository;
  String? _routeId;
  String? _busId;

  @override
  FutureOr<DriverRouteState> build() async {
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      final isOnline = next.maybeWhen(data: (value) => value, orElse: () => false);
      if (isOnline) {
        _syncCachedAttendanceIfOnline();
      }
    });

    final isOnline = ref.watch(connectivityProvider).when(
          data: (value) => value,
          loading: () => true,
          error: (_, __) => false,
        );
    return _loadRoute(isOnline: isOnline);
  }

  bool _isOnline() {
    return ref.read(connectivityProvider).when(
          data: (value) => value,
          loading: () => true,
          error: (_, __) => false,
        );
  }

  DriverRepository _repositoryForConnectivity(bool isOnline) {
    if (!isOnline) {
      return MockDriverRepository();
    }

    return ref.read(driverRepositoryProvider);
  }

  Future<void> _syncCachedAttendanceIfOnline() async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded) return;

    final isOnline = _isOnline();
    if (!isOnline) return;

    _repository = _repositoryForConnectivity(isOnline);

    final cacheService = ref.read(attendanceCacheProvider);
    final syncedStudents = await _syncPendingCachedAttendance(
      repository: _repository,
      students: currentState.students,
      cacheService: cacheService,
    );

    final boardedCount = syncedStudents
        .where((student) => student.status == AttendanceStatus.boarded)
        .length;
    final progress = syncedStudents.isEmpty
        ? 0.0
        : boardedCount / syncedStudents.length;

    state = AsyncData(
      DriverRouteLoaded(
        stops: currentState.stops,
        students: syncedStudents,
        routeProgress: progress,
        gpsStatus: _gpsStatusFor(
          progress: progress,
          lastGpsUpdateAt: currentState.lastGpsUpdateAt,
        ),
        lastGpsUpdateAt: currentState.lastGpsUpdateAt,
      ),
    );
  }

  Future<DriverRouteState> _loadRoute({required bool isOnline}) async {
    final cacheService = ref.read(attendanceCacheProvider);
    final repository = _repositoryForConnectivity(isOnline);
    _repository = repository;

    List<RouteStop> stops = <RouteStop>[];
    List<Student> students = <Student>[];

    if (isOnline) {
      try {
        stops = await repository.fetchRouteStops();
        students = await repository.fetchRouteStudents();
      } catch (_) {
        stops = <RouteStop>[];
        students = <Student>[];
      }
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
    } else if (_repository is FirestoreDriverRepository) {
      final metadata = await (_repository as FirestoreDriverRepository).fetchRouteMetadata();
      _routeId = metadata['routeId'];
      _busId = metadata['busId'];
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
      gpsStatus: _gpsStatusFor(progress: progress),
    );
  }

  Future<void> loadRoute() async {
    final isOnline = await ref.watch(connectivityProvider.future);
    state = await AsyncValue.guard(() => _loadRoute(isOnline: isOnline));
  }

  Future<void> updateStudentAttendanceStatus({
    required String studentId,
    required AttendanceStatus status,
  }) async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded) return;

    final currentStudent = currentState.students.firstWhere(
      (student) => student.id == studentId,
      orElse: () => Student(id: studentId, name: '', stopName: '', grade: ''),
    );
    final cacheService = ref.read(attendanceCacheProvider);
    final isOnline = ref.read(connectivityProvider).maybeWhen(
          data: (value) => value,
          orElse: () => false,
        );

    if (isOnline) {
      _repository = _repositoryForConnectivity(isOnline);
    }

    state = const AsyncLoading<DriverRouteState>();

    late Student updatedStudent;
    if (status == AttendanceStatus.notBoarded) {
      updatedStudent = currentStudent.copyWith(status: status);
      await cacheService.deleteRecord(studentId);
    } else if (!isOnline) {
      _repository = MockDriverRepository();
      updatedStudent = await _repository.updateStudentAttendanceStatus(
        studentId,
        status,
        routeId: '',
        busId: '',
      );
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
      try {
        final repository = _repository;
        updatedStudent = await repository
            .updateStudentAttendanceStatus(
              studentId,
              status,
              routeId: _routeId,
              busId: _busId,
            )
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        _repository = MockDriverRepository();
        updatedStudent = await _repository.updateStudentAttendanceStatus(
          studentId,
          status,
          routeId: '',
          busId: '',
        );
      }
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
        gpsStatus: _gpsStatusFor(
          progress: progress,
          lastGpsUpdateAt: currentState.lastGpsUpdateAt,
        ),
        lastGpsUpdateAt: currentState.lastGpsUpdateAt,
      ),
    );
  }
  Future<void> updateBusLocation({
    required double latitude,
    required double longitude,
  }) async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded) return;

    state = const AsyncLoading<DriverRouteState>();

    try {
      await _repository.updateBusLocation(
        latitude,
        longitude,
        routeId: _routeId,
        busId: _busId,
      );
      final now = DateTime.now();
      state = AsyncData(
        DriverRouteLoaded(
          stops: currentState.stops,
          students: currentState.students,
          routeProgress: currentState.routeProgress,
          gpsStatus: _gpsStatusFor(
            progress: currentState.routeProgress,
            lastGpsUpdateAt: now,
          ),
          lastGpsUpdateAt: now,
        ),
      );
    } catch (_) {
      state = AsyncError(
        DriverRouteError(message: 'Unable to update bus location.'),
        StackTrace.current,
      );
    }
  }
  Future<List<Student>> _syncPendingCachedAttendance({
    required DriverRepository repository,
    required List<Student> students,
    required AttendanceCacheService cacheService,
  }) async {
    final isOnline = _isOnline();
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
          routeId: _routeId,
          busId: _busId,
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

  String _gpsStatusFor({
    required double progress,
    DateTime? lastGpsUpdateAt,
  }) {
    if (lastGpsUpdateAt != null) {
      final elapsed = DateTime.now().difference(lastGpsUpdateAt);
      if (elapsed.inMinutes < 1) {
        return 'GPS live • updated just now';
      }
      return 'GPS live • updated ${elapsed.inMinutes} min ago';
    }

    return progress >= 1.0
        ? 'All students marked'
        : 'Route progress ${(progress * 100).round()}%';
  }
}
