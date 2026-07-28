/// Firestore field-name constants for the driver feature.
///
/// Covers two document shapes:
///
/// **Attendance record** — written to
/// `routes/{routeId}/attendance/{attendanceId}` (or the top-level
/// `attendance` collection as a fallback):
/// ```json
/// {
///   "attendanceId": "<auto-id>",
///   "studentId":    "<studentId>",
///   "routeId":      "<routeId>",
///   "busId":        "<busId>",
///   "status":       "boarded" | "alighted",
///   "date":         "<ISO-8601 date string>",
///   "timestamp":    <Firestore server timestamp>,
///   "recordedBy":   "driver_app"
/// }
/// ```
///
/// **Bus GPS document** — merged into `buses/{busId}`:
/// ```json
/// {
///   "busLocation": { "latitude": 0.0, "longitude": 0.0 },
///   "lastUpdatedAt": <Firestore server timestamp>
/// }
/// ```
class DriverFirestoreFields {
  const DriverFirestoreFields._();

  // ── Attendance record fields ──────────────────────────────────────────────

  /// Auto-generated document ID stored inside the document for easy reference.
  static const String attendanceId = 'attendanceId';

  /// The Firestore document ID of the student being marked.
  static const String studentId = 'studentId';

  /// The route this attendance record belongs to.
  static const String routeId = 'routeId';

  /// The bus operating this route at the time of the mark.
  static const String busId = 'busId';

  /// Attendance status string — one of [boarded] or [alighted].
  static const String status = 'status';

  /// ISO-8601 date string set at write time (client clock).
  static const String date = 'date';

  /// Firestore server timestamp written via [FieldValue.serverTimestamp].
  static const String timestamp = 'timestamp';

  /// Identifies the source of the write; always `"driver_app"` for records
  /// created by this repository.
  static const String recordedBy = 'recordedBy';

  // ── Attendance status values ──────────────────────────────────────────────

  /// Student has boarded the bus.
  static const String boarded = 'boarded';

  /// Student has alighted (dropped off) or was marked absent.
  static const String alighted = 'alighted';

  /// Explicit absent value stored in the `students` canonical document.
  static const String absent = 'absent';

  // ── Bus GPS update fields ─────────────────────────────────────────────────

  /// Map field containing [latitude] and [longitude] sub-fields.
  static const String busLocation = 'busLocation';

  /// WGS-84 latitude in decimal degrees.
  static const String latitude = 'latitude';

  /// WGS-84 longitude in decimal degrees.
  static const String longitude = 'longitude';

  /// Firestore server timestamp updated on every GPS write.
  static const String lastUpdatedAt = 'lastUpdatedAt';

  // ── Driver alert fields ───────────────────────────────────────────────────

  /// Auto-generated document ID stored inside the alert document.
  static const String alertId = 'alertId';

  /// Short title of the alert (e.g. `"Road closure on Route A"`).
  static const String alertTitle = 'title';

  /// Full alert message body.
  static const String alertMessage = 'message';

  /// Alert type string — e.g. `"general"`, `"sos"`, `"arrival"`.
  static const String alertType = 'type';

  /// Whether the driver has read/acknowledged this alert.
  static const String alertIsRead = 'isRead';
}
