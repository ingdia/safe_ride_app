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

class MarkStudentAttendance extends DriverRouteEvent {
  const MarkStudentAttendance({
    required this.studentId,
    required this.status,
  });

  final String studentId;
  final AttendanceStatus status;
}
