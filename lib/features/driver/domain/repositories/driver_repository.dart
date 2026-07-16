import '../models/route_stop.dart';
import '../models/student.dart';

/// Repository contract for driver route and attendance data.
abstract class DriverRepository {
  /// Loads the current driver's route stops.
  Future<List<RouteStop>> fetchRouteStops();

  /// Loads the students assigned to the current route.
  Future<List<Student>> fetchRouteStudents();

  /// Updates a student's attendance status.
  Future<Student> updateStudentAttendanceStatus(
    String studentId,
    AttendanceStatus status,
  );
}
