import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../shared/providers/attendance_cache_provider.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../data/datasources/driver_stream_service.dart';
import '../../data/datasources/attendance_cache_service.dart';
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

/// Exposes a live [Stream] of [Student]s assigned to [busId].
///
/// Re-emits on every Admin roster change (add / remove student) so
/// [StudentAttendanceScreen] reflects mid-trip edits without a manual refresh.
/// Emits an empty list when [busId] is empty or no students match.
final studentRosterStreamProvider =
    StreamProvider.family<List<Student>, String>((ref, busId) {
  if (busId.isEmpty) return const Stream.empty();
  return ref.watch(driverStreamServiceProvider).studentsStream(busId);
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
  String? _tripId;
  bool _online = true;
  Timer? _gpsTimer;
  Set<String> _stopsCompleted = {};

  @override
  FutureOr<DriverRouteState> build() async {
    ref.listen<AsyncValue<bool>>(connectivityProvider, (_, next) {
      final isOnline = next.maybeWhen(data: (value) => value, orElse: () => false);
      _online = isOnline;
      if (isOnline) {
        _syncCachedAttendanceIfOnline();
      }
    });

    _online = ref.read(connectivityProvider).when(
      data: (v) => v,
      loading: () => false,
      error: (error, stackTrace) => false,
    );

    ref.onDispose(() => _gpsTimer?.cancel());

    if (!ref.mounted) return const DriverRouteInitial();
    return _loadRoute(isOnline: _online);
  }

  bool _isOnline() => _online;

  DriverRepository _repositoryForConnectivity(bool isOnline) {
    if (!isOnline) {
      return MockDriverRepository();
    }

    return ref.read(driverRepositoryProvider);
  }

  Future<void> _syncCachedAttendanceIfOnline() async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded) return;
    if (!_isOnline()) return;

    final cacheService = ref.read(attendanceCacheProvider);

    // Batch-push all unsynced records to Firestore and delete them from cache.
    await cacheService.syncOfflineData();

    // Merge any remaining cache entries (e.g. written mid-sync) into state.
    final remaining = await cacheService.loadAll();
    final mergedStudents = currentState.students.map((s) {
      final record = remaining[s.id];
      return record == null ? s : s.copyWith(status: AttendanceStatus.values[record.statusIndex]);
    }).toList();

    final boardedCount = mergedStudents
        .where((s) => s.status == AttendanceStatus.boarded)
        .length;
    final progress =
        mergedStudents.isEmpty ? 0.0 : boardedCount / mergedStudents.length;

    state = AsyncData(
      DriverRouteLoaded(
        stops: currentState.stops,
        students: mergedStudents,
        routeId: _routeId,
        busId: _busId,
        tripId: _tripId,
        routeProgress: progress,
        gpsStatus: _gpsStatusFor(
          progress: progress,
          lastGpsUpdateAt: currentState.lastGpsUpdateAt,
        ),
        lastGpsUpdateAt: currentState.lastGpsUpdateAt,
        stopsCompleted: _stopsCompleted,
        isOffline: !_online,
      ),
    );
  }

  Future<DriverRouteState> _loadRoute({required bool isOnline}) async {
    _online = isOnline;
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

      // Real, empty data (e.g. the admin hasn't finished setting up this
      // bus's route/stops, or approved any students on it yet) is a
      // legitimate state — it must NOT fall back to mock data, or the
      // driver would see fake stops/students no matter what's actually in
      // Firestore, with no way to tell it's fake. DriverRouteLoaded and its
      // screens handle empty stops/students as a real "not set up yet"
      // state instead.
      if (_repository is FirestoreDriverRepository) {
        final metadata = await (_repository as FirestoreDriverRepository).fetchRouteMetadata();
        _routeId = metadata['routeId'];
        _busId = metadata['busId'];
        if (_busId != null && _busId!.isNotEmpty) {
          _tripId = await repository.findActiveTripId(busId: _busId!);
          if (_tripId != null) {
            _startGpsBroadcast();
            _stopsCompleted = (await repository.fetchStopsCompleted(_tripId!)).toSet();
          }
        }
      }
    } else {
      // Genuinely offline (no connectivity at all) — this is the only case
      // mock data is appropriate, as a degraded fallback so the driver can
      // still mark attendance locally and sync later.
      final mockRepository = MockDriverRepository();
      _repository = mockRepository;
      try {
        stops = await mockRepository.fetchRouteStops();
        students = await mockRepository.fetchRouteStudents();
      } catch (error) {
        return DriverRouteError(message: error.toString());
      }
    }

    final cached = await cacheService.loadAll();
    final merged = students.map((student) {
      final record = cached[student.id];
      if (record == null) return student;
      return student.copyWith(
        status: AttendanceStatus.values[record.statusIndex],
      );
    }).toList();

    // If online, push any pending cached records to Firestore now.
    if (isOnline) await cacheService.syncOfflineData();

    // Re-read cache after sync (entries written mid-sync survive).
    final postSync = await cacheService.loadAll();
    final syncedStudents = merged.map((s) {
      final record = postSync[s.id];
      return record == null ? s : s.copyWith(status: AttendanceStatus.values[record.statusIndex]);
    }).toList();

    final boardedCount = syncedStudents
        .where((student) => student.status == AttendanceStatus.boarded)
        .length;
    final progress = syncedStudents.isEmpty
        ? 0.0
        : boardedCount / syncedStudents.length;

    return DriverRouteLoaded(
      stops: stops,
      students: syncedStudents,
      routeId: _routeId,
      busId: _busId,
      tripId: _tripId,
      routeProgress: progress,
      gpsStatus: _gpsStatusFor(progress: progress),
      stopsCompleted: _stopsCompleted,
      isOffline: !_online,
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
    final isOnline = ref.read(connectivityProvider).when(
          data: (v) => v,
          loading: () => _online,
          error: (error, stackTrace) => false,
        );

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
          routeId: _routeId ?? '',
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
              tripId: _tripId,
            )
            .timeout(const Duration(seconds: 8));
        await cacheService.deleteRecord(updatedStudent.id);
      } catch (_) {
        // The write itself failed or timed out — a transient
        // Firestore/network problem, not "device offline" (connectivityProvider
        // said online, that's how we got into this branch at all). Treat it
        // the same as the offline path: apply the change locally and queue
        // it for retry via the existing cache/sync mechanism, instead of
        // silently discarding it or permanently swapping every future write
        // this session to the mock repository (which used to happen here —
        // it meant one transient error made every subsequent write for the
        // rest of the session silently go nowhere, with no visible sign of
        // it, since this failure isn't what OfflineDataBanner tracks).
        updatedStudent = currentStudent.copyWith(status: status);
        await cacheService.saveRecord(
          CachedAttendanceRecord(
            studentId: updatedStudent.id,
            studentName: updatedStudent.name,
            stopName: updatedStudent.stopName,
            statusIndex: updatedStudent.status.index,
            recordedAt: DateTime.now(),
            synced: false,
            routeId: _routeId ?? '',
          ),
        );
      }
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
        routeId: _routeId,
        busId: _busId,
        tripId: _tripId,
        routeProgress: progress,
        gpsStatus: _gpsStatusFor(
          progress: progress,
          lastGpsUpdateAt: currentState.lastGpsUpdateAt,
        ),
        lastGpsUpdateAt: currentState.lastGpsUpdateAt,
        stopsCompleted: _stopsCompleted,
        isOffline: !_online,
      ),
    );
  }

  /// Marks [stopName] as passed on the active trip — writes to Firestore
  /// (which is what the admin activity feed and parent tracking screen
  /// read) and updates local state immediately.
  Future<void> markStopCompleted(String stopName) async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded || !currentState.isTripActive) return;
    if (_stopsCompleted.contains(stopName)) return;

    _stopsCompleted = {..._stopsCompleted, stopName};
    state = AsyncData(
      DriverRouteLoaded(
        stops: currentState.stops,
        students: currentState.students,
        routeId: _routeId,
        busId: _busId,
        tripId: _tripId,
        routeProgress: currentState.routeProgress,
        gpsStatus: currentState.gpsStatus,
        lastGpsUpdateAt: currentState.lastGpsUpdateAt,
        stopsCompleted: _stopsCompleted,
        isOffline: !_online,
      ),
    );

    try {
      await _repository.markStopCompleted(tripId: _tripId!, stopName: stopName);
    } catch (_) {
      // Best-effort — if this fails the stop just won't show as passed for
      // anyone else; the driver can tap it again.
      _stopsCompleted = {..._stopsCompleted}..remove(stopName);
    }
  }

  /// Starts a trip for the driver's assigned bus/route: creates (or resumes)
  /// a `trips` document and begins periodic GPS broadcasting. No-op if a
  /// trip is already active.
  Future<void> startTrip() async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded) return;
    if (currentState.isTripActive) return;
    if (_busId == null || _busId!.isEmpty) {
      state = AsyncError(
        const DriverRouteError(
          message: 'No bus assigned yet. Contact your school administrator.',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading<DriverRouteState>();
    try {
      _tripId = await _repository.startTrip(busId: _busId!, routeId: _routeId ?? '');
      _stopsCompleted = {}; // fresh trip — no stops passed yet
      _startGpsBroadcast();
      state = AsyncData(
        DriverRouteLoaded(
          stops: currentState.stops,
          students: currentState.students,
          routeId: _routeId,
          busId: _busId,
          tripId: _tripId,
          routeProgress: currentState.routeProgress,
          gpsStatus: 'Trip started',
          stopsCompleted: _stopsCompleted,
          isOffline: !_online,
        ),
      );
    } catch (_) {
      state = AsyncError(
        const DriverRouteError(message: 'Unable to start the trip.'),
        StackTrace.current,
      );
    }
  }

  /// Ends the active trip and stops GPS broadcasting.
  Future<void> endTrip() async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded || !currentState.isTripActive) return;

    state = const AsyncLoading<DriverRouteState>();
    try {
      await _repository.endTrip(_tripId!);
      _stopGpsBroadcast();
      _tripId = null;
      state = AsyncData(
        DriverRouteLoaded(
          stops: currentState.stops,
          students: currentState.students,
          routeId: _routeId,
          busId: _busId,
          tripId: null,
          routeProgress: currentState.routeProgress,
          gpsStatus: 'Trip completed',
          stopsCompleted: _stopsCompleted,
          isOffline: !_online,
        ),
      );
    } catch (_) {
      state = AsyncError(
        const DriverRouteError(message: 'Unable to end the trip.'),
        StackTrace.current,
      );
    }
  }

  void _startGpsBroadcast() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 8), (_) => _broadcastCurrentPosition());
    _broadcastCurrentPosition();
  }

  void _stopGpsBroadcast() {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }

  Future<void> _broadcastCurrentPosition() async {
    if (_busId == null || _busId!.isEmpty) return;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high), // ignore: deprecated_member_use
      );
      await updateBusLocation(latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      // Silently skip this tick — the next timer fire will retry.
    }
  }

  Future<void> updateBusLocation({
    required double latitude,
    required double longitude,
  }) async {
    final currentState = state.value;
    if (currentState is! DriverRouteLoaded) return;

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
          routeId: _routeId,
          busId: _busId,
          tripId: _tripId,
          routeProgress: currentState.routeProgress,
          gpsStatus: _gpsStatusFor(
            progress: currentState.routeProgress,
            lastGpsUpdateAt: now,
          ),
          lastGpsUpdateAt: now,
          stopsCompleted: _stopsCompleted,
          isOffline: !_online,
        ),
      );
    } catch (_) {
      state = AsyncError(
        DriverRouteError(message: 'Unable to update bus location.'),
        StackTrace.current,
      );
    }
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
