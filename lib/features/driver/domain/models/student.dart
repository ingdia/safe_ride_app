/// Boarding status for a student on a given stop/route.
enum AttendanceStatus { notBoarded, boarded, absent }

/// A student assigned to the driver's current route.
///
/// Plain data model for now — in Task 2 these will come from
/// `DriverRepository` (mocked) via `DriverRouteBloc` instead of the
/// static list in [StudentAttendanceScreen].
class Student {
  const Student({
    required this.id,
    required this.name,
    required this.stopName,
    required this.grade,
    this.status = AttendanceStatus.notBoarded,
  });

  final String id;
  final String name;
  final String stopName;
  final String grade;
  final AttendanceStatus status;

  Student copyWith({AttendanceStatus? status}) {
    return Student(
      id: id,
      name: name,
      stopName: stopName,
      grade: grade,
      status: status ?? this.status,
    );
  }
}