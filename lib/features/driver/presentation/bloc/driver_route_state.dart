import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';

abstract class DriverRouteState {
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
    this.routeProgress = 0.0,
    this.gpsStatus = 'Waiting for route start',
  });

  final List<RouteStop> stops;
  final List<Student> students;
  final double routeProgress;
  final String gpsStatus;
}

class DriverRouteError extends DriverRouteState {
  const DriverRouteError({required this.message});

  final String message;
}
