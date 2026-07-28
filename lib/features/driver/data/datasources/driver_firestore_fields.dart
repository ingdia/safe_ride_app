class DriverFirestoreFields {
  const DriverFirestoreFields._();

  // Attendance record fields.
  static const String attendanceId = 'attendanceId';
  static const String studentId = 'studentId';
  static const String routeId = 'routeId';
  static const String busId = 'busId';
  static const String status = 'status';
  static const String date = 'date';
  static const String timestamp = 'timestamp';
  static const String recordedBy = 'recordedBy';

  // Attendance status values.
  static const String boarded = 'boarded';
  static const String alighted = 'alighted';
  static const String absent = 'absent';

  // Bus GPS update fields.
  static const String busLocation = 'busLocation';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String lastUpdatedAt = 'lastUpdatedAt';
}
