import '../../domain/models/student.dart';
import '../../domain/models/route_stop.dart';

sealed class DriverRouteState {
  const DriverRouteState();
}

class DriverRouteInitial extends DriverRouteState {
  const DriverRouteInitial();
}

class DriverRouteLoading extends DriverRouteState {
  const DriverRouteLoading();
}

class DriverRouteLoaded extends DriverRouteState {
  const DriverRouteLoaded({
    required this.stops,
    required this.students,
    this.routeId,
    this.busId,
    this.tripId,
    this.routeProgress = 0.0,
    this.gpsStatus = 'Waiting for GPS',
    this.lastGpsUpdateAt,
    this.stopsCompleted = const {},
  });

  final List<RouteStop> stops;
  final List<Student> students;
  /// The Firestore route document ID, or `null` when using mock data.
  final String? routeId;
  final String? busId;
  /// The active `trips/{tripId}` document id, or `null` if no trip has been
  /// started yet.
  final String? tripId;
  final double routeProgress;
  final String gpsStatus;
  final DateTime? lastGpsUpdateAt;

  /// Stop names the driver has explicitly marked as passed on the active
  /// trip — mirrors `trips/{tripId}.stopsCompleted` in Firestore.
  final Set<String> stopsCompleted;

  bool get isTripActive => tripId != null && tripId!.isNotEmpty;
}

class DriverRouteError extends DriverRouteState {
  const DriverRouteError({required this.message});

  final String message;
}
