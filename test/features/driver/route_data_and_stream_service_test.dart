import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/driver/data/datasources/driver_firestore_fields.dart';
import 'package:safe_ride_app/features/driver/data/datasources/driver_firestore_paths.dart';
import 'package:safe_ride_app/features/driver/data/datasources/driver_stream_service.dart';
import 'package:safe_ride_app/features/driver/data/models/route_data.dart';
import 'package:safe_ride_app/features/driver/domain/models/route_stop.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';

// ── shared seed helpers ───────────────────────────────────────────────────────

Map<String, dynamic> _routeDoc({
  String name = 'Route A',
  String busId = 'bus_001',
  String driverId = 'driver_001',
  String status = 'inProgress',
  String scheduledTime = '07:45',
  int? etaMinutes = 10,
  List<Map<String, dynamic>>? stops,
}) =>
    {
      'name': name,
      'busId': busId,
      'driverId': driverId,
      'status': status,
      'scheduledTime': scheduledTime,
      if (etaMinutes != null) 'etaMinutes': etaMinutes,
      'stops': stops ??
          [
            {
              'order': 2,
              'name': 'Maple Ave',
              'studentCount': 2,
              'time': '7:55 AM',
              'status': 'upcoming',
              'isDestination': false,
            },
            {
              'order': 1,
              'name': 'Oak Street',
              'studentCount': 3,
              'time': '7:45 AM',
              'status': 'current',
              'isDestination': false,
            },
          ],
    };

Map<String, dynamic> _alertDoc({
  String routeId = 'route_001',
  String title = 'Road closure',
  String message = 'Avoid Kimironko junction',
  String type = 'general',
  bool isRead = false,
  Timestamp? timestamp,
}) =>
    {
      DriverFirestoreFields.routeId: routeId,
      DriverFirestoreFields.alertTitle: title,
      DriverFirestoreFields.alertMessage: message,
      DriverFirestoreFields.alertType: type,
      DriverFirestoreFields.alertIsRead: isRead,
      DriverFirestoreFields.timestamp:
          timestamp ?? Timestamp.fromDate(DateTime(2025, 1, 1, 8, 0)),
    };

Map<String, dynamic> _studentDoc({
  String name = 'Alice',
  String stopName = 'Oak Street',
  String grade = 'P3',
  String attendanceStatus = 'notBoarded',
  String busId = 'bus_001',
}) =>
    {
      'name': name,
      'stopName': stopName,
      'grade': grade,
      // Distinct from `status`, which holds the school-approval state
      // (pending/approved/rejected) — attendance marks must never touch it.
      'attendanceStatus': attendanceStatus,
      DriverFirestoreFields.busId: busId,
    };

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── RouteData model parsing ───────────────────────────────────────────────

  group('RouteData.fromFirestore', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() => fakeFirestore = FakeFirebaseFirestore());

    Future<DocumentSnapshot<Map<String, dynamic>>> _seedAndGet(
      Map<String, dynamic> data, {
      String docId = 'route_001',
    }) async {
      await fakeFirestore
          .collection(DriverFirestorePaths.routes)
          .doc(docId)
          .set(data);
      return fakeFirestore
          .collection(DriverFirestorePaths.routes)
          .doc(docId)
          .get();
    }

    test('parses all scalar fields correctly', () async {
      final snap = await _seedAndGet(_routeDoc());
      final route = RouteData.fromFirestore(snap);

      expect(route.routeId, 'route_001');
      expect(route.name, 'Route A');
      expect(route.busId, 'bus_001');
      expect(route.driverId, 'driver_001');
      expect(route.status, RouteStatus.inProgress);
      expect(route.scheduledTime, '07:45');
      expect(route.etaMinutes, 10);
    });

    test('stops are sorted by order field ascending', () async {
      // Seed with order 2 before order 1 — parser must sort them.
      final snap = await _seedAndGet(_routeDoc());
      final route = RouteData.fromFirestore(snap);

      expect(route.stops, hasLength(2));
      expect(route.stops[0].order, 1);
      expect(route.stops[0].name, 'Oak Street');
      expect(route.stops[1].order, 2);
      expect(route.stops[1].name, 'Maple Ave');
    });

    test('stop status strings map to correct RouteStopStatus values', () async {
      final snap = await _seedAndGet(_routeDoc(stops: [
        {'order': 1, 'name': 'A', 'studentCount': 1, 'time': '7:00', 'status': 'completed', 'isDestination': false},
        {'order': 2, 'name': 'B', 'studentCount': 1, 'time': '7:10', 'status': 'current', 'isDestination': false},
        {'order': 3, 'name': 'C', 'studentCount': 1, 'time': '7:20', 'status': 'upcoming', 'isDestination': false},
      ]));
      final stops = RouteData.fromFirestore(snap).stops;

      expect(stops[0].status, RouteStopStatus.completed);
      expect(stops[1].status, RouteStopStatus.current);
      expect(stops[2].status, RouteStopStatus.upcoming);
    });

    test('unknown status string defaults to RouteStatus.scheduled', () async {
      final snap = await _seedAndGet(_routeDoc(status: 'unknown_value'));
      expect(RouteData.fromFirestore(snap).status, RouteStatus.scheduled);
    });

    test('all four RouteStatus strings parse correctly', () async {
      for (final pair in [
        ('scheduled', RouteStatus.scheduled),
        ('inProgress', RouteStatus.inProgress),
        ('completed', RouteStatus.completed),
        ('cancelled', RouteStatus.cancelled),
      ]) {
        final snap = await _seedAndGet(_routeDoc(status: pair.$1), docId: pair.$1);
        expect(RouteData.fromFirestore(snap).status, pair.$2,
            reason: 'status "${pair.$1}" should parse to ${pair.$2}');
      }
    });

    test('missing optional fields fall back to safe defaults', () async {
      // Minimal document — only required Firestore ID, no other fields.
      final snap = await _seedAndGet({});
      final route = RouteData.fromFirestore(snap);

      expect(route.name, '');
      expect(route.busId, '');
      expect(route.driverId, '');
      expect(route.status, RouteStatus.scheduled);
      expect(route.scheduledTime, '');
      expect(route.etaMinutes, isNull);
      expect(route.stops, isEmpty);
    });

    test('etaMinutes is null when field is absent', () async {
      final snap = await _seedAndGet(_routeDoc(etaMinutes: null));
      expect(RouteData.fromFirestore(snap).etaMinutes, isNull);
    });

    test('stops list is empty when field is absent', () async {
      final data = Map<String, dynamic>.from(_routeDoc())..remove('stops');
      final snap = await _seedAndGet(data);
      expect(RouteData.fromFirestore(snap).stops, isEmpty);
    });

    test('toMap round-trips through fromFirestore', () async {
      final snap = await _seedAndGet(_routeDoc());
      final original = RouteData.fromFirestore(snap);

      // Write toMap output back and re-parse.
      await fakeFirestore
          .collection(DriverFirestorePaths.routes)
          .doc('round_trip')
          .set(original.toMap());
      final snap2 = await fakeFirestore
          .collection(DriverFirestorePaths.routes)
          .doc('round_trip')
          .get();
      final reparsed = RouteData.fromFirestore(snap2);

      expect(reparsed.name, original.name);
      expect(reparsed.busId, original.busId);
      expect(reparsed.driverId, original.driverId);
      expect(reparsed.status, original.status);
      expect(reparsed.scheduledTime, original.scheduledTime);
      expect(reparsed.etaMinutes, original.etaMinutes);
      expect(reparsed.stops.length, original.stops.length);
    });

    test('copyWith replaces only the supplied fields', () async {
      final snap = await _seedAndGet(_routeDoc());
      final original = RouteData.fromFirestore(snap);
      final copy = original.copyWith(name: 'Route B', etaMinutes: 5);

      expect(copy.name, 'Route B');
      expect(copy.etaMinutes, 5);
      // Unchanged fields preserved.
      expect(copy.busId, original.busId);
      expect(copy.driverId, original.driverId);
      expect(copy.status, original.status);
      expect(copy.routeId, original.routeId);
    });

    test('isDestination flag is parsed correctly', () async {
      final snap = await _seedAndGet(_routeDoc(stops: [
        {'order': 1, 'name': 'School', 'studentCount': 0, 'time': '8:00', 'status': 'upcoming', 'isDestination': true},
      ]));
      expect(RouteData.fromFirestore(snap).stops.first.isDestination, isTrue);
    });
  });

  // ── DriverStreamService — routeDataStream ─────────────────────────────────

  group('DriverStreamService.routeDataStream', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DriverStreamService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = DriverStreamService(firestore: fakeFirestore);
    });

    test('emits null when document does not exist', () async {
      expect(
        service.routeDataStream('nonexistent'),
        emits(isNull),
      );
    });

    test('emits parsed RouteData when document exists', () async {
      await fakeFirestore
          .collection(DriverFirestorePaths.routes)
          .doc('route_001')
          .set(_routeDoc());

      final first = await service.routeDataStream('route_001').first;

      expect(first, isNotNull);
      expect(first!.routeId, 'route_001');
      expect(first.name, 'Route A');
      expect(first.busId, 'bus_001');
      expect(first.status, RouteStatus.inProgress);
      expect(first.stops, hasLength(2));
    });

    test('re-emits updated RouteData when document is written', () async {
      final ref = fakeFirestore
          .collection(DriverFirestorePaths.routes)
          .doc('route_001');

      await ref.set(_routeDoc(status: 'scheduled'));

      final stream = service.routeDataStream('route_001');

      // First emission: scheduled.
      expect(
        stream,
        emitsInOrder([
          predicate<RouteData?>((r) => r?.status == RouteStatus.scheduled),
          predicate<RouteData?>((r) => r?.status == RouteStatus.inProgress),
        ]),
      );

      // Trigger second emission.
      await ref.update({'status': 'inProgress'});
    });

    test('emits null then RouteData when document is created after subscription', () async {
      final ref = fakeFirestore
          .collection(DriverFirestorePaths.routes)
          .doc('route_late');

      expect(
        service.routeDataStream('route_late'),
        emitsInOrder([
          isNull,
          predicate<RouteData?>((r) => r?.name == 'Late Route'),
        ]),
      );

      await ref.set(_routeDoc(name: 'Late Route'));
    });
  });

  // ── DriverStreamService — alertsStream ────────────────────────────────────

  group('DriverStreamService.alertsStream', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DriverStreamService service;
    const routeId = 'route_001';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = DriverStreamService(firestore: fakeFirestore);
    });

    test('emits empty list when no alerts exist', () async {
      expect(
        service.alertsStream(routeId),
        emits(isEmpty),
      );
    });

    test('emits list with one parsed alert after seeding', () async {
      await fakeFirestore
          .collection(DriverFirestorePaths.driverAlertsCollection(routeId))
          .doc('alert_001')
          .set(_alertDoc(title: 'Test alert', message: 'Check route'));

      final alerts = await service.alertsStream(routeId).first;

      expect(alerts, hasLength(1));
      expect(alerts.first.alertId, 'alert_001');
      expect(alerts.first.title, 'Test alert');
      expect(alerts.first.message, 'Check route');
      expect(alerts.first.type, 'general');
      expect(alerts.first.isRead, isFalse);
    });

    test('alerts are ordered by timestamp descending (newest first)', () async {
      final col =
          fakeFirestore.collection(DriverFirestorePaths.driverAlertsCollection(routeId));

      final older = Timestamp.fromDate(DateTime(2025, 1, 1, 7, 0));
      final newer = Timestamp.fromDate(DateTime(2025, 1, 1, 9, 0));

      await col.doc('alert_old').set(_alertDoc(title: 'Old', timestamp: older));
      await col.doc('alert_new').set(_alertDoc(title: 'New', timestamp: newer));

      final alerts = await service.alertsStream(routeId).first;

      expect(alerts, hasLength(2));
      expect(alerts[0].title, 'New');
      expect(alerts[1].title, 'Old');
    });

    test('re-emits updated list when a new alert document is added', () async {
      final col =
          fakeFirestore.collection(DriverFirestorePaths.driverAlertsCollection(routeId));

      expect(
        service.alertsStream(routeId),
        emitsInOrder([
          isEmpty,
          hasLength(1),
        ]),
      );

      await col.doc('alert_001').set(_alertDoc());
    });

    test('sos type alert is parsed with correct type field', () async {
      await fakeFirestore
          .collection(DriverFirestorePaths.driverAlertsCollection(routeId))
          .doc('sos_001')
          .set(_alertDoc(type: 'sos', title: 'Emergency'));

      final alerts = await service.alertsStream(routeId).first;
      expect(alerts.first.type, 'sos');
    });

    test('alert timestamp is parsed from Firestore Timestamp', () async {
      final ts = Timestamp.fromDate(DateTime(2025, 6, 15, 8, 30));
      await fakeFirestore
          .collection(DriverFirestorePaths.driverAlertsCollection(routeId))
          .doc('alert_ts')
          .set(_alertDoc(timestamp: ts));

      final alerts = await service.alertsStream(routeId).first;
      expect(alerts.first.timestamp, DateTime(2025, 6, 15, 8, 30));
    });
  });

  // ── DriverStreamService — studentsStream ──────────────────────────────────

  group('DriverStreamService.studentsStream', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DriverStreamService service;
    // studentsStream filters students by `busId`, not `routeId` — the
    // `students` security rule only grants a driver access via
    // `resource.data.busId == myBusId()`, so the query has to match that
    // field. See DriverStreamService.studentsStream.
    const busId = 'bus_001';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = DriverStreamService(firestore: fakeFirestore);
    });

    test('emits empty list when no students match busId', () async {
      // Seed a student on a different bus — should not appear.
      await fakeFirestore
          .collection('students')
          .doc('stu_other')
          .set(_studentDoc(busId: 'bus_999'));

      expect(
        service.studentsStream(busId),
        emits(isEmpty),
      );
    });

    test('emits parsed Student list filtered by busId', () async {
      await fakeFirestore
          .collection('students')
          .doc('stu_001')
          .set(_studentDoc(name: 'Alice', busId: busId));
      // Different bus — must be excluded.
      await fakeFirestore
          .collection('students')
          .doc('stu_other')
          .set(_studentDoc(name: 'Bob', busId: 'bus_999'));

      final students = await service.studentsStream(busId).first;

      expect(students, hasLength(1));
      expect(students.first.id, 'stu_001');
      expect(students.first.name, 'Alice');
    });

    test('attendance status strings map to correct AttendanceStatus values', () async {
      final col = fakeFirestore.collection('students');
      await col.doc('stu_boarded').set(_studentDoc(attendanceStatus: 'boarded', busId: busId, stopName: 'A'));
      await col.doc('stu_alighted').set(_studentDoc(attendanceStatus: 'alighted', busId: busId, stopName: 'B'));
      await col.doc('stu_absent').set(_studentDoc(attendanceStatus: 'absent', busId: busId, stopName: 'C'));
      await col.doc('stu_default').set(_studentDoc(attendanceStatus: 'notBoarded', busId: busId, stopName: 'D'));

      final students = await service.studentsStream(busId).first;
      final byId = {for (final s in students) s.id: s};

      expect(byId['stu_boarded']!.status, AttendanceStatus.boarded);
      expect(byId['stu_alighted']!.status, AttendanceStatus.absent);
      expect(byId['stu_absent']!.status, AttendanceStatus.absent);
      expect(byId['stu_default']!.status, AttendanceStatus.notBoarded);
    });

    test('re-emits updated list when a student document changes', () async {
      final ref = fakeFirestore.collection('students').doc('stu_001');
      await ref.set(_studentDoc(attendanceStatus: 'notBoarded', busId: busId));

      expect(
        service.studentsStream(busId),
        emitsInOrder([
          predicate<List<Student>>(
              (list) => list.isNotEmpty && list.first.status == AttendanceStatus.notBoarded),
          predicate<List<Student>>(
              (list) => list.isNotEmpty && list.first.status == AttendanceStatus.boarded),
        ]),
      );

      await ref.update({'attendanceStatus': 'boarded'});
    });

    test('stopName falls back to routeStop field when stopName is absent', () async {
      await fakeFirestore.collection('students').doc('stu_001').set({
        'name': 'Alice',
        'routeStop': 'Kigali Heights',
        'grade': 'P4',
        'attendanceStatus': 'notBoarded',
        DriverFirestoreFields.busId: busId,
      });

      final students = await service.studentsStream(busId).first;
      expect(students.first.stopName, 'Kigali Heights');
    });
  });
}
