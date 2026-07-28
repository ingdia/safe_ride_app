/// Canonical Firestore collection and document path constants for the driver
/// feature.
///
/// All attendance writes and GPS updates reference paths built from these
/// constants, keeping path strings in one place and avoiding magic strings
/// scattered across the codebase.
///
/// Firestore schema overview:
/// ```
/// routes/{routeId}
///   └── attendance/{attendanceId}   ← per-trip attendance records
///
/// buses/{busId}                     ← live GPS location (merged on every update)
///
/// drivers/{driverId}                ← driver profile documents
/// students/{studentId}              ← canonical student status (denormalised)
/// ```
class DriverFirestorePaths {
  const DriverFirestorePaths._();

  /// Top-level collection that holds all driver profile documents.
  static const String drivers = 'drivers';

  /// Top-level collection that holds all route documents.
  static const String routes = 'routes';

  /// Top-level fallback attendance collection used when no [routeId] is
  /// available. Prefer [routeAttendanceCollection] for scoped writes.
  static const String attendance = 'attendance';

  /// Top-level collection that holds bus documents, each updated in-place with
  /// the latest GPS coordinates via
  /// [FirestoreDriverRepository.updateBusLocation].
  static const String buses = 'buses';

  /// Path to a single driver document: `drivers/{driverId}`.
  static String driverDocument(String driverId) => '$drivers/$driverId';

  /// Path to a single route document: `routes/{routeId}`.
  static String routeDocument(String routeId) => '$routes/$routeId';

  /// Path to a single bus document: `buses/{busId}`.
  static String busDocument(String busId) => '$buses/$busId';

  /// Path to the attendance **subcollection** scoped to a route:
  /// `routes/{routeId}/attendance`.
  ///
  /// Each document in this subcollection represents one attendance event
  /// (boarded / alighted) recorded by the driver during a trip. This is the
  /// primary write target for
  /// [FirestoreDriverRepository.updateStudentAttendanceStatus].
  static String routeAttendanceCollection(String routeId) =>
      '$routes/$routeId/$attendance';

  /// Path to a specific attendance record:
  /// `routes/{routeId}/attendance/{attendanceId}`.
  static String routeAttendanceDocument(String routeId, String attendanceId) =>
      '$routes/$routeId/$attendance/$attendanceId';

  /// Path to the bus document used for GPS updates: `buses/{busId}`.
  static String busLocationField(String busId) => '$buses/$busId';
}
