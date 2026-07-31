import '../models/route_stop.dart';
import '../models/student.dart';

/// Repository contract for driver route, trip and attendance data.
///
/// Implementations must handle both online (Firestore) and offline (mock/cache)
/// scenarios. The concrete Firestore implementation is
/// [FirestoreDriverRepository]; [MockDriverRepository] is used in tests and
/// when no network is available.
abstract class DriverRepository {
  /// Returns the ordered list of stops for the driver's own assigned route
  /// (resolved from the signed-in driver's `users/{uid}.busId`).
  Future<List<RouteStop>> fetchRouteStops();

  /// Returns approved students assigned to the driver's own bus.
  Future<List<Student>> fetchRouteStudents();

  /// Records a boarding/drop-off event for [studentId] against the active
  /// trip and returns the updated [Student].
  ///
  /// - [status] must be [AttendanceStatus.boarded] or
  ///   [AttendanceStatus.absent] (used to represent "dropped off"). Passing
  ///   [AttendanceStatus.notBoarded] is a no-op that returns a stub student
  ///   without writing to Firestore.
  /// - [tripId] identifies the `trips/{tripId}` document whose
  ///   `studentEvents` map gets the event — the parent app watches this
  ///   document, so a null/empty [tripId] means the parent won't see the
  ///   update.
  Future<Student> updateStudentAttendanceStatus(
    String studentId,
    AttendanceStatus status, {
    String? routeId,
    String? busId,
    String? tripId,
  });

  /// Writes the bus's current GPS coordinates to `busLocations/{busId}`.
  /// The write is skipped silently when [busId] cannot be resolved.
  Future<void> updateBusLocation(
    double latitude,
    double longitude, {
    String? routeId,
    String? busId,
  });

  /// Returns the id of a trip already `inProgress` for [busId], if any.
  ///
  /// [schoolId] should be passed whenever known — the `trips` security rule
  /// gates reads on `schoolId`, so a query missing that filter is rejected
  /// outright rather than just returning no results.
  Future<String?> findActiveTripId({required String busId, String? schoolId});

  /// Returns the stop names already marked passed on [tripId] — lets the
  /// driver's own screen show the correct state if they reopen the app
  /// mid-trip, not just whatever they've tapped this session.
  Future<List<String>> fetchStopsCompleted(String tripId);

  /// Creates a new `trips` document (or resumes an existing in-progress one)
  /// for the driver's assigned bus/route and returns its id.
  ///
  /// [schoolId] should be passed whenever the caller already has it — see
  /// [findActiveTripId]. When omitted it's resolved from the signed-in
  /// driver's own profile.
  Future<String> startTrip({
    required String busId,
    required String routeId,
    String? schoolId,
  });

  /// Marks [tripId] as completed.
  Future<void> endTrip(String tripId);

  /// Marks [stopName] as passed on [tripId] — distinct from the parent
  /// app's GPS-proximity guess, this is the driver's own confirmation.
  /// Also what triggers the admin "bus passed this stop" notification.
  Future<void> markStopCompleted({required String tripId, required String stopName});
}
