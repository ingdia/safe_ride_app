import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_firestore_paths.dart';
import '../datasources/driver_firestore_fields.dart';

/// Firestore-backed implementation of [DriverRepository].
class FirestoreDriverRepository implements DriverRepository {
  FirestoreDriverRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<RouteStop>> fetchRouteStops() async {
    try {
      final query = await _firestore.collection(DriverFirestorePaths.routes).get();

      final stops = query.docs.map((doc) {
        final data = doc.data();

        // Support two shapes:
        // 1) Each document represents a stop with top-level fields.
        // 2) A route document contains a list field (e.g. `stops` or `routeStops`).

        if (data.containsKey('stops') && data['stops'] is List) {
          final rawStops = data['stops'] as List;
          return rawStops.map((s) => _mapRouteStopFromMap(s as Map<String, dynamic>)).toList();
        }

        return [_mapRouteStopFromMap(data)];
      }).expand((e) => e).toList();

      // Ensure ordering by `order` field.
      stops.sort((a, b) => a.order.compareTo(b.order));

      return stops;
    } catch (_) {
      // Return an empty list if Firestore fails (including web JS interop issues).
      return <RouteStop>[];
    }
  }

  @override
  Future<List<Student>> fetchRouteStudents() async {
    try {
      // Try to read a top-level `students` collection; if it doesn't exist return empty list.
      final collectionRef = _firestore.collection('students');
      final snapshot = await collectionRef.get();

      final students = snapshot.docs.map((doc) => _mapStudentFromDoc(doc)).toList();
      return students;
    } catch (_) {
      return <Student>[];
    }
  }

  @override
  Future<Student> updateStudentAttendanceStatus(
    String studentId,
    AttendanceStatus status, {
    String? routeId,
    String? busId,
  }) async {
    try {
      final attendanceRef = _firestore.collection(DriverFirestorePaths.attendance).doc();

      final statusValue = _attendanceStatusToString(status);

      final data = <String, dynamic>{
        DriverFirestoreFields.attendanceId: attendanceRef.id,
        DriverFirestoreFields.studentId: studentId,
        DriverFirestoreFields.status: statusValue,
        DriverFirestoreFields.timestamp: FieldValue.serverTimestamp(),
        DriverFirestoreFields.recordedBy: 'driver_app',
        DriverFirestoreFields.date: DateTime.now().toIso8601String(),
        DriverFirestoreFields.routeId: routeId ?? '',
        DriverFirestoreFields.busId: busId ?? '',
      };

      await attendanceRef.set(data);

      // If a `students/{studentId}` document exists, update its status field to keep canonical state.
      final studentDocRef = _firestore.collection('students').doc(studentId);
      final studentSnapshot = await studentDocRef.get();

      if (studentSnapshot.exists) {
        await studentDocRef.update({
          'status': statusValue,
        });
        return _mapStudentFromDoc(await studentDocRef.get());
      }

      // If student doc does not exist, return a lightweight Student instance with updated status.
      return Student(
        id: studentId,
        name: '',
        stopName: '',
        grade: '',
        status: status,
      );
    } catch (_) {
      // If Firestore fails, return a lightweight Student with the requested status so UI can continue.
      return Student(
        id: studentId,
        name: '',
        stopName: '',
        grade: '',
        status: status,
      );
    }
  }

  RouteStop _mapRouteStopFromMap(Map<String, dynamic> data) {
    final order = (data['order'] is num) ? (data['order'] as num).toInt() : 0;
    final name = (data['name'] as String?) ?? '';
    final studentCount = (data['studentCount'] is num) ? (data['studentCount'] as num).toInt() : 0;
    final time = (data['time'] as String?) ?? '';
    final statusStr = (data['status'] as String?) ?? 'upcoming';
    final isDestination = (data['isDestination'] is bool) ? (data['isDestination'] as bool) : false;

    RouteStopStatus status;
    if (statusStr == 'completed') {
      status = RouteStopStatus.completed;
    } else if (statusStr == 'current') {
      status = RouteStopStatus.current;
    } else {
      status = RouteStopStatus.upcoming;
    }

    return RouteStop(
      order: order,
      name: name,
      studentCount: studentCount,
      time: time,
      status: status,
      isDestination: isDestination,
    );
  }

  Student _mapStudentFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final id = doc.id;
    final name = (data['name'] as String?) ?? (data['studentId'] as String?) ?? '';
    final stopName = (data['stopName'] as String?) ?? (data['routeStop'] as String?) ?? '';
    final grade = (data['grade'] as String?) ?? '';
    final statusStr = (data['status'] as String?) ?? 'notBoarded';

    final status = _attendanceStatusFromString(statusStr);

    return Student(
      id: id,
      name: name,
      stopName: stopName,
      grade: grade,
      status: status,
    );
  }

  AttendanceStatus _attendanceStatusFromString(String value) {
    switch (value) {
      case DriverFirestoreFields.boarded:
        return AttendanceStatus.boarded;
      case DriverFirestoreFields.absent:
        return AttendanceStatus.absent;
      default:
        return AttendanceStatus.notBoarded;
    }
  }

  String _attendanceStatusToString(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.boarded:
        return DriverFirestoreFields.boarded;
      case AttendanceStatus.absent:
        return DriverFirestoreFields.absent;
      case AttendanceStatus.notBoarded:
        return DriverFirestoreFields.dropped; // map notBoarded->dropped as default write value
    }
  }
}
