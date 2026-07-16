import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';

/// Mock implementation of [DriverRepository] for Task 2.
class MockDriverRepository implements DriverRepository {
  MockDriverRepository();

  static final List<RouteStop> _mockStops = [
    const RouteStop(
      order: 1,
      name: 'Oak Street',
      studentCount: 3,
      time: '7:45 AM',
    ),
    const RouteStop(
      order: 2,
      name: 'Maple Avenue',
      studentCount: 2,
      time: '7:52 AM',
    ),
    const RouteStop(
      order: 3,
      name: 'Cedar Lane',
      studentCount: 4,
      time: '8:00 AM',
    ),
    const RouteStop(
      order: 4,
      name: 'Birch Court',
      studentCount: 1,
      time: '8:07 AM',
    ),
    const RouteStop(
      order: 5,
      name: 'Kigali Parents School',
      studentCount: 0,
      time: '8:15 AM',
      isDestination: true,
    ),
  ];

  static final List<Student> _mockStudents = [
    const Student(
      id: 's1',
      name: 'Emma Johnson',
      stopName: 'Oak Street',
      grade: 'Grade 3',
    ),
    const Student(
      id: 's2',
      name: 'Liam Uwimana',
      stopName: 'Oak Street',
      grade: 'Grade 2',
    ),
    const Student(
      id: 's3',
      name: 'Aline Mukamana',
      stopName: 'Oak Street',
      grade: 'Grade 4',
    ),
    const Student(
      id: 's4',
      name: 'Noah Habimana',
      stopName: 'Maple Avenue',
      grade: 'Grade 1',
    ),
    const Student(
      id: 's5',
      name: 'Grace Ineza',
      stopName: 'Maple Avenue',
      grade: 'Grade 3',
    ),
  ];

  final List<Student> _students = List.of(_mockStudents);

  @override
  Future<List<RouteStop>> fetchRouteStops() async {
    return List.unmodifiable(_mockStops);
  }

  @override
  Future<List<Student>> fetchRouteStudents() async {
    return List.unmodifiable(_students);
  }

  @override
  Future<Student> updateStudentAttendanceStatus(
    String studentId,
    AttendanceStatus status,
  ) async {
    final index = _students.indexWhere((student) => student.id == studentId);
    if (index == -1) {
      throw StateError('Student not found: $studentId');
    }

    final updatedStudent = _students[index].copyWith(status: status);
    _students[index] = updatedStudent;
    return updatedStudent;
  }
}
