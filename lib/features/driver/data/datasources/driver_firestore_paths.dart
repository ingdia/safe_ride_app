class DriverFirestorePaths {
  const DriverFirestorePaths._();

  static const String drivers = 'drivers';
  static const String routes = 'routes';
  static const String attendance = 'attendance';
  static const String buses = 'buses';

  static String driverDocument(String driverId) => '$drivers/$driverId';
  static String routeDocument(String routeId) => '$routes/$routeId';
  static String busDocument(String busId) => '$buses/$busId';

  static String routeAttendanceCollection(String routeId) =>
      '$routes/$routeId/$attendance';

  static String routeAttendanceDocument(String routeId, String attendanceId) =>
      '$routes/$routeId/$attendance/$attendanceId';

  static String busLocationField(String busId) => '$buses/$busId';
}
