import '../models/route_stop.dart';
import '../models/student.dart';

/// Repository contract for driver route and attendance data.
///
/// Implementations must handle both online (Firestore) and offline (mock/cache)
/// scenarios. The concrete Firestore implementation is
/// [FirestoreDriverRepository]; [MockDriverRepository] is used in tests and
/// when no network is available.
abstract class DriverRepository {
  /// Returns the ordered list of stops for the driver's active route.
  Future<List<RouteStop>> fetchRouteStops();

  /// Returns all students assigned to the driver's active route.
  Future<List<Student>> fetchRouteStudents();

  /// Records an attendance event for [studentId] and returns the updated
  /// [Student].
  ///
  /// - [status] must be [AttendanceStatus.boarded] or
  ///   [AttendanceStatus.absent]. Passing [AttendanceStatus.notBoarded] is a
  ///   no-op that returns a stub student without writing to Firestore.
  /// - [routeId] and [busId] are optional; when omitted the implementation
  ///   resolves them from Firestore route metadata.
  ///
  /// **Firestore write path:**
  /// `routes/{routeId}/attendance/{auto-id}` (falls back to top-level
  /// `attendance/{auto-id}` when [routeId] is empty).
  ///
  /// The canonical `students/{studentId}` document is also updated so that
  /// Admin and Parent listeners see the change in real time.
  Future<Student> updateStudentAttendanceStatus(
    String studentId,
    AttendanceStatus status, {
    String? routeId,
    String? busId,
  });

  /// Writes the bus's current GPS coordinates to Firestore.
  ///
  /// Uses [SetOptions.merge] so only the location fields are touched and
  /// existing bus metadata is preserved.
  ///
  /// **Firestore write path:** `buses/{busId}`
  ///
  /// The write is skipped silently when [busId] cannot be resolved.
  Future<void> updateBusLocation(
    double latitude,
    double longitude, {
    String? routeId,
    String? busId,
  });
}
