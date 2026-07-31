import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/core/firebase/firebase_collections.dart';
import 'package:safe_ride_app/features/driver/data/repositories/firestore_driver_repository.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreDriverRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    // No FirebaseAuth override is supplied — these tests exercise only the
    // paths that accept an explicit routeId/busId/tripId, since resolving
    // the signed-in driver's own assignment requires a real Firebase Auth
    // session (covered by the driver_route_provider_test.dart integration
    // tests instead, which run against MockDriverRepository).
    repository = FirestoreDriverRepository(firestore: fakeFirestore);
  });

  Future<void> seedStudent(String studentId, {String name = 'Alice'}) async {
    await fakeFirestore.collection(FirebaseCollections.students).doc(studentId).set({
      'name': name,
      'stopName': 'Oak Street',
      'grade': 'P3',
      'status': 'approved',
    });
  }

  // ── trip lifecycle ─────────────────────────────────────────────────────

  group('startTrip / findActiveTripId / endTrip', () {
    const busId = 'bus_001';
    const routeId = 'route_001';

    test('startTrip creates an inProgress trips document', () async {
      final tripId = await repository.startTrip(busId: busId, routeId: routeId);

      final doc = await fakeFirestore.collection(FirebaseCollections.trips).doc(tripId).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['busId'], busId);
      expect(doc.data()!['routeId'], routeId);
      expect(doc.data()!['status'], 'inProgress');
    });

    test('startTrip resumes an already-active trip instead of creating a new one', () async {
      final firstId = await repository.startTrip(busId: busId, routeId: routeId);
      final secondId = await repository.startTrip(busId: busId, routeId: routeId);

      expect(secondId, firstId);
      final snap = await fakeFirestore
          .collection(FirebaseCollections.trips)
          .where('busId', isEqualTo: busId)
          .get();
      expect(snap.docs, hasLength(1));
    });

    test('findActiveTripId returns null when no trip is in progress', () async {
      final tripId = await repository.findActiveTripId(busId: busId);
      expect(tripId, isNull);
    });

    test('endTrip marks the trip completed', () async {
      final tripId = await repository.startTrip(busId: busId, routeId: routeId);
      await repository.endTrip(tripId);

      final doc = await fakeFirestore.collection(FirebaseCollections.trips).doc(tripId).get();
      expect(doc.data()!['status'], 'completed');
      expect(doc.data()!.containsKey('completedAt'), isTrue);

      // No longer discoverable as the active trip.
      expect(await repository.findActiveTripId(busId: busId), isNull);
    });
  });

  // ── attendance writes ──────────────────────────────────────────────────

  group('updateStudentAttendanceStatus', () {
    const studentId = 'stu_001';
    const busId = 'bus_001';
    const routeId = 'route_001';

    test('writes into trips/{tripId}.studentEvents and students.attendanceStatus', () async {
      await seedStudent(studentId);
      final tripId = await repository.startTrip(busId: busId, routeId: routeId);

      await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.boarded,
        tripId: tripId,
      );

      final tripDoc = await fakeFirestore.collection(FirebaseCollections.trips).doc(tripId).get();
      expect(tripDoc.data()!['studentEvents'], {studentId: 'boarded'});

      final studentDoc =
          await fakeFirestore.collection(FirebaseCollections.students).doc(studentId).get();
      expect(studentDoc.data()!['attendanceStatus'], 'boarded');
      // The approval-status field must be untouched by an attendance mark.
      expect(studentDoc.data()!['status'], 'approved');
    });

    test('absent status is recorded as droppedOff in studentEvents', () async {
      await seedStudent(studentId);
      final tripId = await repository.startTrip(busId: busId, routeId: routeId);

      await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.absent,
        tripId: tripId,
      );

      final tripDoc = await fakeFirestore.collection(FirebaseCollections.trips).doc(tripId).get();
      expect(tripDoc.data()!['studentEvents'], {studentId: 'droppedOff'});
    });

    test('notBoarded skips all Firestore writes and returns a stub student', () async {
      await seedStudent(studentId);
      final tripId = await repository.startTrip(busId: busId, routeId: routeId);

      final result = await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.notBoarded,
        tripId: tripId,
      );

      expect(result.status, AttendanceStatus.notBoarded);
      final tripDoc = await fakeFirestore.collection(FirebaseCollections.trips).doc(tripId).get();
      expect(tripDoc.data()!['studentEvents'], isEmpty);
    });

    test('missing tripId still updates the student doc without throwing', () async {
      await seedStudent(studentId);

      final result = await repository.updateStudentAttendanceStatus(
        studentId,
        AttendanceStatus.boarded,
      );

      expect(result.status, AttendanceStatus.boarded);
      final studentDoc =
          await fakeFirestore.collection(FirebaseCollections.students).doc(studentId).get();
      expect(studentDoc.data()!['attendanceStatus'], 'boarded');
    });
  });

  // ── GPS / bus location writes ──────────────────────────────────────────

  group('updateBusLocation', () {
    const busId = 'bus_001';

    test('writes lat/lng/updatedAt to busLocations/{busId}', () async {
      await repository.updateBusLocation(-1.9445, 30.0612, busId: busId);

      final doc =
          await fakeFirestore.collection(FirebaseCollections.busLocations).doc(busId).get();
      expect(doc.data()!['lat'], -1.9445);
      expect(doc.data()!['lng'], 30.0612);
      expect(doc.data()!.containsKey('updatedAt'), isTrue);
    });

    test('successive writes update the same document in place (merge)', () async {
      await repository.updateBusLocation(-1.9445, 30.0612, busId: busId);
      await repository.updateBusLocation(-1.9500, 30.0700, busId: busId);

      final snap = await fakeFirestore.collection(FirebaseCollections.busLocations).get();
      expect(snap.docs.where((d) => d.id == busId), hasLength(1));

      final doc =
          await fakeFirestore.collection(FirebaseCollections.busLocations).doc(busId).get();
      expect(doc.data()!['lat'], -1.9500);
      expect(doc.data()!['lng'], 30.0700);
    });

    test('skips the write when busId cannot be resolved', () async {
      await repository.updateBusLocation(-1.9445, 30.0612);

      final snap = await fakeFirestore.collection(FirebaseCollections.busLocations).get();
      expect(snap.docs, isEmpty);
    });
  });

  // ── unauthenticated fallback behavior ──────────────────────────────────

  group('fetchRouteStops / fetchRouteStudents without an authenticated driver', () {
    test('both return an empty list rather than throwing', () async {
      expect(await repository.fetchRouteStops(), isEmpty);
      expect(await repository.fetchRouteStudents(), isEmpty);
    });
  });
}
