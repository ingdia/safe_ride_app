import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_firestore_paths.dart';

/// Firestore-backed implementation of [DriverRepository].
///
/// ## Route/bus resolution
///
/// Every read/write below is scoped to the *signed-in driver's own*
/// assignment — resolved via [fetchRouteMetadata] from
/// `users/{uid}.busId`, then the `routes` document with a matching `busId`.
/// This is what keeps one driver from ever seeing another route's roster.
///
/// ## Trip lifecycle
///
/// [startTrip]/[endTrip] manage the canonical `trips/{tripId}` document the
/// parent app streams from. [updateStudentAttendanceStatus] writes into that
/// same document's `studentEvents` map so boarding/drop-off events reach the
/// parent in real time; [updateBusLocation] writes to `busLocations/{busId}`
/// on every GPS tick, which is what the parent's live map renders.
class FirestoreDriverRepository implements DriverRepository {
  FirestoreDriverRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authOverride = auth;

  final FirebaseFirestore _firestore;
  // Resolved lazily (not in the constructor) so constructing this repository
  // never requires a live Firebase App — only actually calling a method that
  // needs the signed-in user does, and that path already fails safe via the
  // try/catch in fetchRouteMetadata.
  final FirebaseAuth? _authOverride;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  /// Resolves the signed-in driver's own `busId`/`routeId`/`schoolId`.
  /// Returns an empty map when not authenticated or not yet assigned.
  Future<Map<String, String?>> fetchRouteMetadata() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return {};

      final userDoc = await _firestore.collection(FirebaseCollections.users).doc(uid).get();
      final data = userDoc.data();
      final busId = data?['busId'] as String?;
      final schoolId = data?['schoolId'] as String?;
      var routeId = data?['routeId'] as String?;

      if (busId == null || busId.isEmpty) return {'schoolId': schoolId};

      // 1. Try resolving routeId from the bus document if not on user doc
      if (routeId == null || routeId.isEmpty) {
        final busDoc = await _firestore.collection(DriverFirestorePaths.buses).doc(busId).get();
        routeId = busDoc.data()?['routeId'] as String?;
      }

      // 2. Try querying routes by schoolId & busId
      if (routeId == null || routeId.isEmpty) {
        final routeQuery = await _firestore
            .collection(DriverFirestorePaths.routes)
            .where('schoolId', isEqualTo: schoolId)
            .where('busId', isEqualTo: busId)
            .limit(1)
            .get();
        if (routeQuery.docs.isNotEmpty) {
          routeId = routeQuery.docs.first.id;
        }
      }

      // 3. Fallback: try finding any route for this school
      if ((routeId == null || routeId.isEmpty) && schoolId != null && schoolId.isNotEmpty) {
        final schoolRouteQuery = await _firestore
            .collection(DriverFirestorePaths.routes)
            .where('schoolId', isEqualTo: schoolId)
            .limit(1)
            .get();
        if (schoolRouteQuery.docs.isNotEmpty) {
          routeId = schoolRouteQuery.docs.first.id;
        }
      }

      return {
        'busId': busId,
        'schoolId': schoolId,
        'routeId': routeId,
        'driverId': uid,
      };
    } catch (_) {
      return {};
    }
  }

  @override
  Future<List<RouteStop>> fetchRouteStops() async {
    try {
      final metadata = await fetchRouteMetadata();
      final routeId = metadata['routeId'];
      if (routeId == null || routeId.isEmpty) return <RouteStop>[];

      final doc = await _firestore.collection(DriverFirestorePaths.routes).doc(routeId).get();
      final data = doc.data();
      if (data == null || data['stops'] is! List) return <RouteStop>[];

      final stops = (data['stops'] as List)
          .whereType<Map<String, dynamic>>()
          .map(_mapRouteStopFromMap)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return stops;
    } catch (_) {
      return <RouteStop>[];
    }
  }

  @override
  Future<List<Student>> fetchRouteStudents() async {
    try {
      final metadata = await fetchRouteMetadata();
      final busId = metadata['busId'];
      if (busId == null || busId.isEmpty) return <Student>[];

      final snapshot = await _firestore
          .collection(FirebaseCollections.students)
          .where('busId', isEqualTo: busId)
          .get();

      return snapshot.docs
          .where((doc) {
            final status = doc.data()['status'] as String?;
            return status == null || status == 'approved' || status == 'active';
          })
          .map(_mapStudentFromDoc)
          .toList();
    } catch (_) {
      return <Student>[];
    }
  }

  @override
  Future<String?> findActiveTripId({required String busId, String? schoolId}) async {
    // The `trips` rule gates reads on `schoolId`; a query missing that
    // filter is rejected by Firestore outright, so resolve it first if the
    // caller didn't already have it.
    final resolvedSchoolId = schoolId ?? (await fetchRouteMetadata())['schoolId'];
    if (resolvedSchoolId == null || resolvedSchoolId.isEmpty) return null;

    final query = await _firestore
        .collection(FirebaseCollections.trips)
        .where('schoolId', isEqualTo: resolvedSchoolId)
        .where('busId', isEqualTo: busId)
        .where('status', isEqualTo: 'inProgress')
        .limit(1)
        .get();
    return query.docs.isEmpty ? null : query.docs.first.id;
  }

  @override
  Future<String> startTrip({required String busId, required String routeId, String? schoolId}) async {
    final metadata = await fetchRouteMetadata();
    final resolvedSchoolId = schoolId ?? metadata['schoolId'];
    final existing = await findActiveTripId(busId: busId, schoolId: resolvedSchoolId);
    if (existing != null) return existing;

    final hour = DateTime.now().hour;
    final tripRef = await _firestore.collection(FirebaseCollections.trips).add({
      'routeId': routeId,
      'busId': busId,
      'driverId': metadata['driverId'] ?? '',
      'schoolId': resolvedSchoolId ?? '',
      'type': hour < 12 ? 'morning' : 'afternoon',
      'status': 'inProgress',
      'startedAt': FieldValue.serverTimestamp(),
      'studentEvents': <String, dynamic>{},
    });
    return tripRef.id;
  }

  @override
  Future<void> endTrip(String tripId) async {
    await _firestore.collection(FirebaseCollections.trips).doc(tripId).set({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markStopCompleted({required String tripId, required String stopName}) async {
    await _firestore.collection(FirebaseCollections.trips).doc(tripId).update({
      'stopsCompleted': FieldValue.arrayUnion([stopName]),
    });
  }

  @override
  Future<List<String>> fetchStopsCompleted(String tripId) async {
    final doc = await _firestore.collection(FirebaseCollections.trips).doc(tripId).get();
    final raw = doc.data()?['stopsCompleted'] as List<dynamic>? ?? [];
    return raw.map((e) => e as String).toList();
  }

  @override
  Future<Student> updateStudentAttendanceStatus(
    String studentId,
    AttendanceStatus status, {
    String? routeId,
    String? busId,
    String? tripId,
  }) async {
    if (status == AttendanceStatus.notBoarded) {
      return Student(id: studentId, name: '', stopName: '', grade: '', status: status);
    }

    final statusValue = _attendanceStatusToString(status);

    // Deliberately no try/catch here — the caller (DriverRouteNotifier)
    // needs a thrown exception to detect a failed write and queue it for
    // offline retry. Swallowing errors here and returning a stub Student
    // used to make every failure look like a success, silently losing the
    // attendance mark with no retry and no visible sign anything went
    // wrong.
    if (tripId != null && tripId.isNotEmpty) {
      await _firestore.collection(FirebaseCollections.trips).doc(tripId).update({
        'studentEvents.$studentId': statusValue == 'boarded' ? 'boarded' : 'droppedOff',
      });
    }

    // Note: uses a distinct `attendanceStatus` field, not `status` — the
    // `status` field on a student doc means pending/approved/rejected
    // (school-approval state) and must never be overwritten here.
    final studentDocRef = _firestore.collection(FirebaseCollections.students).doc(studentId);
    final studentSnapshot = await studentDocRef.get();
    if (!studentSnapshot.exists) {
      throw StateError('Student $studentId no longer exists.');
    }

    await studentDocRef.update({'attendanceStatus': statusValue});
    return _mapStudentFromDoc(await studentDocRef.get());
  }

  @override
  Future<void> updateBusLocation(
    double latitude,
    double longitude, {
    String? routeId,
    String? busId,
  }) async {
    final resolvedBusId = (busId != null && busId.isNotEmpty)
        ? busId
        : (await fetchRouteMetadata())['busId'] ?? '';

    if (resolvedBusId.isEmpty) return;

    await _firestore.collection(FirebaseCollections.busLocations).doc(resolvedBusId).set({
      'lat': latitude,
      'lng': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  RouteStop _mapRouteStopFromMap(Map<String, dynamic> data) {
    final order = (data['order'] is num) ? (data['order'] as num).toInt() : 0;
    final name = (data['name'] as String?) ?? '';
    final studentCount = (data['studentCount'] is num) ? (data['studentCount'] as num).toInt() : 0;
    final time = (data['time'] as String?) ?? '';
    final statusStr = (data['status'] as String?) ?? 'upcoming';
    final isDestination = (data['isDestination'] is bool) ? (data['isDestination'] as bool) : false;
    final lat = (data['lat'] is num) ? (data['lat'] as num).toDouble() : null;
    final lng = (data['lng'] is num) ? (data['lng'] as num).toDouble() : null;

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
      lat: lat,
      lng: lng,
    );
  }

  Student _mapStudentFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final id = doc.id;
    final name = (data['name'] as String?) ?? '';
    final stopName = (data['stopName'] as String?) ?? '';
    final grade = (data['grade'] as String?) ?? '';
    final statusStr = (data['attendanceStatus'] as String?) ?? 'notBoarded';
    final parentName = data['parentName'] as String?;
    final parentPhone = data['parentPhone'] as String?;

    return Student(
      id: id,
      name: name,
      stopName: stopName,
      grade: grade,
      status: _attendanceStatusFromString(statusStr),
      parentName: parentName,
      parentPhone: parentPhone,
    );
  }

  AttendanceStatus _attendanceStatusFromString(String value) {
    switch (value) {
      case 'boarded':
        return AttendanceStatus.boarded;
      case 'alighted':
      case 'absent':
        return AttendanceStatus.absent;
      default:
        return AttendanceStatus.notBoarded;
    }
  }

  String _attendanceStatusToString(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.boarded:
        return 'boarded';
      case AttendanceStatus.absent:
        return 'alighted';
      case AttendanceStatus.notBoarded:
        return 'alighted';
    }
  }
}
