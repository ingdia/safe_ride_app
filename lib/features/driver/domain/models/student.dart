/// Boarding status for a student on a given stop/route.
enum AttendanceStatus { notBoarded, boarded, absent }

/// A student assigned to the driver's current route, sourced live from
/// `DriverRepository` (Firestore-backed; see [FirestoreDriverRepository]).
class Student {
  const Student({
    required this.id,
    required this.name,
    required this.stopName,
    required this.grade,
    this.status = AttendanceStatus.notBoarded,
    this.parentName,
    this.parentPhone,
  });

  final String id;
  final String name;
  final String stopName;
  final String grade;
  final AttendanceStatus status;

  /// Denormalized from the parent's own profile at student-creation time —
  /// null for students created before that field existed.
  final String? parentName;
  final String? parentPhone;

  Student copyWith({AttendanceStatus? status}) {
    return Student(
      id: id,
      name: name,
      stopName: stopName,
      grade: grade,
      status: status ?? this.status,
      parentName: parentName,
      parentPhone: parentPhone,
    );
  }
}