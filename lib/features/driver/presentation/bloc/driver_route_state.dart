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
  });

  final List<RouteStop> stops;
  final List<Student> students;
}

class DriverRouteError extends DriverRouteState {
  const DriverRouteError({required this.message});

  final String message;
}
