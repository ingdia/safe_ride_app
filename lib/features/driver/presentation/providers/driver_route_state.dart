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
    this.routeProgress = 0.0,
    this.gpsStatus = 'Waiting for GPS',
    this.lastGpsUpdateAt,
  });

  final List<RouteStop> stops;
  final List<Student> students;
  /// The Firestore route document ID, or `null` when using mock data.
  final String? routeId;
  final double routeProgress;
  final String gpsStatus;
  final DateTime? lastGpsUpdateAt;
}

class DriverRouteError extends DriverRouteState {
  const DriverRouteError({required this.message});

  final String message;
}
