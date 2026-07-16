import '../../domain/models/student.dart';

abstract class DriverRouteEvent {
  const DriverRouteEvent();
}

class LoadDriverRoute extends DriverRouteEvent {
  const LoadDriverRoute();
}

class UpdateRouteStops extends DriverRouteEvent {
  const UpdateRouteStops();
}

class UpdateStudentAttendanceStatus extends DriverRouteEvent {
  const UpdateStudentAttendanceStatus({
    required this.studentId,
    required this.status,
  });

  final String studentId;
  final AttendanceStatus status;
}
