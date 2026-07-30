import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/driver/data/datasources/driver_firestore_fields.dart';
import 'package:safe_ride_app/features/driver/data/datasources/driver_firestore_paths.dart';
import 'package:safe_ride_app/features/driver/data/repositories/firestore_driver_repository.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreDriverRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FirestoreDriverRepository(firestore: fakeFirestore);
  });

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<void> seedRoute({
    required String routeId,
    required String busId,
  }) async {
    await fakeFirestore
        .collection(DriverFirestorePaths.routes)
        .doc(routeId)
        .set({'busId': busId, 'name': 'Test Route'});
  }

  Future<void> seedStudent(String studentId, {String name = 'Alice'}) async {
    await fakeFirestore.collection('students').doc(studentId).set({
      'name': name,
      'stopName': 'Oak Street',
      'grade': 'P3',
      'status': 'notBoarded',
    });
  }

  // ── attendance writes ─────────────────────────────────────────────────────

  group('updateStudentAttendanceStatus — Firestore writes', () {
    const routeId = 'route_001';
    const busId = 'bus_001';
    const studentId = 'stu_001';

    setUp(() async {
      await seedRoute(routeId: routeId, busId: busId);
      await seedStudent(studentId);
    });

    test('writes attendance doc to routes/{routeId}/attendance subcollection', () async {
      await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.boarded,
        routeId: routeId,
        busId: busId,
      );

      final snap = await fakeFirestore
          .collection(DriverFirestorePaths.routeAttendanceCollection(routeId))
          .get();

      expect(snap.docs, hasLength(1));
      final data = snap.docs.first.data();
      expect(data[DriverFirestoreFields.studentId], studentId);
      expect(data[DriverFirestoreFields.status], DriverFirestoreFields.boarded);
      expect(data[DriverFirestoreFields.routeId], routeId);
      expect(data[DriverFirestoreFields.busId], busId);
      expect(data[DriverFirestoreFields.recordedBy], 'driver_app');
    });

    test('attendance doc contains attendanceId, date, and timestamp fields', () async {
      await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.boarded,
        routeId: routeId,
        busId: busId,
      );

      final snap = await fakeFirestore
          .collection(DriverFirestorePaths.routeAttendanceCollection(routeId))
          .get();

      final data = snap.docs.first.data();
      expect(data.containsKey(DriverFirestoreFields.attendanceId), isTrue);
      expect(data.containsKey(DriverFirestoreFields.date), isTrue);
      expect(data.containsKey(DriverFirestoreFields.timestamp), isTrue);
    });

    test('writes absent status as "alighted" in Firestore', () async {
      await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.absent,
        routeId: routeId,
        busId: busId,
      );

      final snap = await fakeFirestore
          .collection(DriverFirestorePaths.routeAttendanceCollection(routeId))
          .get();

      expect(
        snap.docs.first.data()[DriverFirestoreFields.status],
        DriverFirestoreFields.alighted,
      );
    });

    test('also updates status field on students/{studentId} document', () async {
      await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.boarded,
        routeId: routeId,
        busId: busId,
      );

      final studentDoc =
          await fakeFirestore.collection('students').doc(studentId).get();
      expect(studentDoc.data()!['status'], DriverFirestoreFields.boarded);
    });

    test('returns Student with correct status after write', () async {
      final result = await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.boarded,
        routeId: routeId,
        busId: busId,
      );

      expect(result.id, studentId);
      expect(result.status, AttendanceStatus.boarded);
    });

    test('notBoarded skips Firestore write and returns stub student', () async {
      await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.notBoarded,
        routeId: routeId,
        busId: busId,
      );

      final snap = await fakeFirestore
          .collection(DriverFirestorePaths.routeAttendanceCollection(routeId))
          .get();

      expect(snap.docs, isEmpty);
    });

    test('falls back to top-level attendance collection when routeId is empty', () async {
      // Use a fresh firestore with no routes so fetchRouteMetadata returns empty.
      final isolatedFirestore = FakeFirebaseFirestore();
      await isolatedFirestore.collection('students').doc(studentId).set({
        'name': 'Alice',
        'stopName': 'Oak Street',
        'grade': 'P3',
        'status': 'notBoarded',
      });
      final isolatedRepo = FirestoreDriverRepository(firestore: isolatedFirestore);

      await isolatedRepo.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.boarded,
        routeId: '',
        busId: '',
      );

      final snap = await isolatedFirestore
          .collection(DriverFirestorePaths.attendance)
          .get();

      expect(snap.docs, hasLength(1));
      expect(
        snap.docs.first.data()[DriverFirestoreFields.studentId],
        studentId,
      );
    });

    test('multiple attendance marks create separate docs in subcollection', () async {
      await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.boarded,
        routeId: routeId,
        busId: busId,
      );
      await repository.updateStudentAttendanceStatus(
        'stu_002',
        AttendanceStatus.absent,
        routeId: routeId,
        busId: busId,
      );

      final snap = await fakeFirestore
          .collection(DriverFirestorePaths.routeAttendanceCollection(routeId))
          .get();

      expect(snap.docs, hasLength(2));
    });
  });

  // ── GPS / bus location writes ─────────────────────────────────────────────

  group('updateBusLocation — Firestore writes', () {
    const routeId = 'route_001';
    const busId = 'bus_001';

    setUp(() async => seedRoute(routeId: routeId, busId: busId));

    test('writes latitude and longitude to buses/{busId}', () async {
      await repository.updateBusLocation(
        -1.9445,
        30.0612,
        routeId: routeId,
        busId: busId,
      );

      final doc = await fakeFirestore
          .collection(DriverFirestorePaths.buses)
          .doc(busId)
          .get();

      final location =
          doc.data()![DriverFirestoreFields.busLocation] as Map<String, dynamic>;
      expect(location[DriverFirestoreFields.latitude], -1.9445);
      expect(location[DriverFirestoreFields.longitude], 30.0612);
    });

    test('bus doc contains lastUpdatedAt field after GPS write', () async {
      await repository.updateBusLocation(
        -1.9445,
        30.0612,
        routeId: routeId,
        busId: busId,
      );

      final doc = await fakeFirestore
          .collection(DriverFirestorePaths.buses)
          .doc(busId)
          .get();

      expect(doc.data()!.containsKey(DriverFirestoreFields.lastUpdatedAt), isTrue);
    });

    test('successive GPS writes update coordinates in place (merge)', () async {
      await repository.updateBusLocation(-1.9445, 30.0612,
          routeId: routeId, busId: busId);
      await repository.updateBusLocation(-1.9500, 30.0700,
          routeId: routeId, busId: busId);

      final docs = await fakeFirestore
          .collection(DriverFirestorePaths.buses)
          .get();

      // merge: still only one document for this bus
      expect(docs.docs.where((d) => d.id == busId), hasLength(1));

      final location = docs.docs
          .firstWhere((d) => d.id == busId)
          .data()[DriverFirestoreFields.busLocation] as Map<String, dynamic>;
      expect(location[DriverFirestoreFields.latitude], -1.9500);
      expect(location[DriverFirestoreFields.longitude], 30.0700);
    });

    test('skips write when busId resolves to empty string', () async {
      // No route seeded → fetchRouteMetadata returns empty busId.
      final emptyRepo = FirestoreDriverRepository(firestore: FakeFirebaseFirestore());

      await emptyRepo.updateBusLocation(-1.9445, 30.0612);

      final snap = await fakeFirestore
          .collection(DriverFirestorePaths.buses)
          .get();
      expect(snap.docs, isEmpty);
    });
  });
}
