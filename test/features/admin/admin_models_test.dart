import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/admin/data/models/attendance_model.dart';
import 'package:safe_ride_app/features/admin/data/models/bus_model.dart';
import 'package:safe_ride_app/features/admin/data/models/route_model.dart';
import 'package:safe_ride_app/features/admin/data/models/student_model.dart';
import 'package:safe_ride_app/features/admin/data/repositories/buses_repository.dart';
import 'package:safe_ride_app/features/admin/data/repositories/routes_repository.dart';

import '../../helpers/fake_document_snapshot.dart';

void main() {
  final createdAt = DateTime(2024, 6, 1, 8, 0);
  final createdAtTs = Timestamp.fromDate(createdAt);

  group('BusModel.fromFirestore', () {
    test('maps all fields correctly', () {
      final doc = FakeDocumentSnapshot('bus-1', {
        'plate_number': 'RAB 001A',
        'capacity': 40,
        'driver_id': 'driver-1',
        'school_id': 'school-1',
        'status': 'active',
        'created_at': createdAtTs,
      });

      final bus = BusModel.fromFirestore(doc);

      expect(bus.busId, 'bus-1');
      expect(bus.plateNumber, 'RAB 001A');
      expect(bus.capacity, 40);
      expect(bus.driverId, 'driver-1');
      expect(bus.schoolId, 'school-1');
      expect(bus.status, BusStatus.active);
      expect(bus.createdAt, createdAt);
    });

    test('defaults to idle status when status field is missing', () {
      final doc = FakeDocumentSnapshot('bus-2', {
        'plate_number': 'RAB 002B',
        'capacity': 30,
        'driver_id': '',
        'school_id': 'school-1',
        'created_at': createdAtTs,
      });

      expect(BusModel.fromFirestore(doc).status, BusStatus.idle);
    });

    test('parses sos status', () {
      final doc = FakeDocumentSnapshot('bus-3', {
        'plate_number': 'RAB 003C',
        'capacity': 20,
        'driver_id': 'driver-2',
        'school_id': 'school-1',
        'status': 'sos',
        'created_at': createdAtTs,
      });

      expect(BusModel.fromFirestore(doc).status, BusStatus.sos);
    });

    test('toFirestore round-trips plate_number and capacity', () {
      final doc = FakeDocumentSnapshot('bus-1', {
        'plate_number': 'RAB 001A',
        'capacity': 40,
        'driver_id': 'driver-1',
        'school_id': 'school-1',
        'status': 'active',
        'created_at': createdAtTs,
      });

      final map = BusModel.fromFirestore(doc).toFirestore();
      expect(map['plate_number'], 'RAB 001A');
      expect(map['capacity'], 40);
      expect(map['status'], 'active');
    });

    test('kBusStaleThresholdDays is 30', () {
      expect(kBusStaleThresholdDays, 30);
    });
  });

  group('RouteModel.fromFirestore', () {
    test('maps all fields including stops', () {
      final doc = FakeDocumentSnapshot('route-1', {
        'school_id': 'school-1',
        'bus_id': 'bus-1',
        'name': 'Route Alpha',
        'stops': [
          {'name': 'Stop A', 'lat': -1.9, 'lng': 30.1, 'order': 0},
          {'name': 'Stop B', 'lat': -1.95, 'lng': 30.15, 'order': 1},
        ],
        'created_at': createdAtTs,
      });

      final route = RouteModel.fromFirestore(doc);

      expect(route.routeId, 'route-1');
      expect(route.name, 'Route Alpha');
      expect(route.busId, 'bus-1');
      expect(route.stops.length, 2);
      expect(route.stops.first.name, 'Stop A');
      expect(route.stops.last.order, 1);
    });

    test('defaults to empty stops list when field is absent', () {
      final doc = FakeDocumentSnapshot('route-2', {
        'school_id': 'school-1',
        'bus_id': '',
        'name': 'Empty Route',
        'created_at': createdAtTs,
      });

      expect(RouteModel.fromFirestore(doc).stops, isEmpty);
    });

    test('toFirestore includes stops as list of maps', () {
      final doc = FakeDocumentSnapshot('route-1', {
        'school_id': 'school-1',
        'bus_id': 'bus-1',
        'name': 'Route Alpha',
        'stops': [
          {'name': 'Stop A', 'lat': -1.9, 'lng': 30.1, 'order': 0},
        ],
        'created_at': createdAtTs,
      });

      final map = RouteModel.fromFirestore(doc).toFirestore();
      expect(map['name'], 'Route Alpha');
      expect((map['stops'] as List).first['name'], 'Stop A');
    });

    test('kRouteStaleThresholdDays is 30', () {
      expect(kRouteStaleThresholdDays, 30);
    });
  });

  group('AttendanceModel.fromFirestore', () {
    final ts = Timestamp.fromDate(DateTime(2024, 6, 1, 7, 30));

    test('maps all fields correctly', () {
      final doc = FakeDocumentSnapshot('att-1', {
        'student_id': 'student-1',
        'route_id': 'route-1',
        'bus_id': 'bus-1',
        'status': 'boarded',
        'date': '2024-06-01',
        'timestamp': ts,
        'recorded_by': 'driver-1',
      });

      final att = AttendanceModel.fromFirestore(doc);

      expect(att.attendanceId, 'att-1');
      expect(att.studentId, 'student-1');
      expect(att.status, AttendanceStatus.boarded);
      expect(att.date, '2024-06-01');
      expect(att.recordedBy, 'driver-1');
    });

    test('defaults to absent when status is unknown', () {
      final doc = FakeDocumentSnapshot('att-2', {
        'student_id': 'student-2',
        'route_id': 'route-1',
        'bus_id': 'bus-1',
        'status': 'unknown_value',
        'date': '2024-06-01',
        'timestamp': ts,
        'recorded_by': 'driver-1',
      });

      expect(AttendanceModel.fromFirestore(doc).status, AttendanceStatus.absent);
    });

    test('parses alighted status', () {
      final doc = FakeDocumentSnapshot('att-3', {
        'student_id': 'student-3',
        'route_id': 'route-1',
        'bus_id': 'bus-1',
        'status': 'alighted',
        'date': '2024-06-01',
        'timestamp': ts,
        'recorded_by': 'driver-1',
      });

      expect(AttendanceModel.fromFirestore(doc).status, AttendanceStatus.alighted);
    });
  });

  group('StudentModel.fromFirestore', () {
    test('maps all fields correctly', () {
      final doc = FakeDocumentSnapshot('student-1', {
        'name': 'Ava Uwase',
        'grade': '3',
        'school_id': 'school-1',
        'parent_id': 'parent-1',
        'route_id': 'route-1',
      });

      final student = StudentModel.fromFirestore(doc);

      expect(student.studentId, 'student-1');
      expect(student.name, 'Ava Uwase');
      expect(student.grade, '3');
      expect(student.schoolId, 'school-1');
      expect(student.parentId, 'parent-1');
      expect(student.routeId, 'route-1');
    });

    test('defaults empty strings for missing fields', () {
      final doc = FakeDocumentSnapshot('student-2', <String, dynamic>{});

      final student = StudentModel.fromFirestore(doc);
      expect(student.name, '');
      expect(student.routeId, '');
    });
  });
}
