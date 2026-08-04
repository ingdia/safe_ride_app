import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../shared/models/bus_location_entity.dart';
import '../../../../shared/models/route_entity.dart';
import '../../../../shared/models/student_entity.dart';
import '../../../../shared/models/trip_entity.dart';
import '../../domain/entities/parent_child_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_profile_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../../domain/utils/eta_calculator.dart';
import '../datasources/parent_firestore_fields.dart';
import '../models/parent_notification_firestore_model.dart';
import 'parent_repository.dart';

class FirestoreParentRepository implements ParentRepository {
  FirestoreParentRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated parent.');
    return uid;
  }

  // ---------------------------------------------------------------------
  // Children (students collection, scoped to this parent)
  // ---------------------------------------------------------------------

  @override
  Stream<List<ParentChildEntity>> watchChildren() {
    return _firestore
        .collection(FirebaseCollections.students)
        .where('parentId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_toParentChild).toList());
  }

  ParentChildEntity _toParentChild(DocumentSnapshot<Map<String, dynamic>> doc) {
    final s = StudentEntity.fromDoc(doc);
    return ParentChildEntity(
      id: s.id,
      fullName: s.name,
      grade: s.grade,
      status: switch (s.status) {
        StudentStatus.pending => ParentChildStatus.pending,
        StudentStatus.approved => ParentChildStatus.approved,
        StudentStatus.rejected => ParentChildStatus.rejected,
      },
      schoolId: s.schoolId,
      busId: s.busId,
      busNumber: s.busNumber,
      pickupStop: s.stopName,
      driverName: s.driverName,
      driverPhone: s.driverPhone,
    );
  }

  @override
  Future<void> addChild({
    required String fullName,
    required String grade,
    required String schoolId,
    required String requestedStop,
  }) async {
    // Denormalized onto the student doc so the driver can see who to
    // contact — drivers have no read access to other users' profiles under
    // the security rules, only to their own bus's student docs.
    final ownProfile = await _firestore.collection(FirebaseCollections.users).doc(_uid).get();
    final parentName = ownProfile.data()?['name'] as String? ?? '';
    final parentPhone = ownProfile.data()?['phone'] as String? ?? '';

    await _firestore.collection(FirebaseCollections.students).add({
      'name': fullName.trim(),
      'grade': grade.trim(),
      'schoolId': schoolId,
      'parentId': _uid,
      'status': 'pending',
      'requestedStop': requestedStop.trim(),
      'parentName': parentName,
      'parentPhone': parentPhone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateChild(ParentChildEntity child) async {
    await _firestore.collection(FirebaseCollections.students).doc(child.id).set({
      'name': child.fullName.trim(),
      'grade': child.grade.trim(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteChild(String childId) async {
    await _firestore.collection(FirebaseCollections.students).doc(childId).delete();
  }

  // ---------------------------------------------------------------------
  // Profile (users/{uid})
  // ---------------------------------------------------------------------

  @override
  Future<ParentProfileEntity> getParentProfile() async {
    final doc = await _firestore.collection(FirebaseCollections.users).doc(_uid).get();
    return _toProfile(doc);
  }

  @override
  Stream<ParentProfileEntity> watchParentProfile() {
    return _firestore
        .collection(FirebaseCollections.users)
        .doc(_uid)
        .snapshots()
        .map(_toProfile);
  }

  ParentProfileEntity _toProfile(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ParentProfileEntity(
      parentId: doc.id,
      fullName: d['name'] as String? ?? _auth.currentUser?.displayName ?? '',
      phoneNumber: d['phone'] as String? ?? '',
      email: d['email'] as String? ?? _auth.currentUser?.email ?? '',
      homeAddress: d['homeAddress'] as String? ?? '',
      preferredLanguage: d['preferredLanguage'] as String? ?? 'English',
      schoolId: d['schoolId'] as String?,
    );
  }

  @override
  Future<void> updateParentProfile(ParentProfileEntity profile) async {
    await _firestore.collection(FirebaseCollections.users).doc(_uid).set({
      'name': profile.fullName,
      'phone': profile.phoneNumber,
      'homeAddress': profile.homeAddress,
      'preferredLanguage': profile.preferredLanguage,
    }, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------

  @override
  Stream<List<ParentNotificationEntity>> watchNotifications() {
    return _firestore
        .collection(FirebaseCollections.notifications)
        .where(ParentNotificationFields.parentId, isEqualTo: _uid)
        .orderBy(ParentNotificationFields.createdAt, descending: true)
        .snapshots()
        .map((s) => s.docs.map(ParentNotificationFirestoreModel.fromSnapshot).toList());
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection(FirebaseCollections.notifications).doc(notificationId).set({
      ParentNotificationFields.isRead: true,
      ParentNotificationFields.readAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    final snapshot = await _firestore
        .collection(FirebaseCollections.notifications)
        .where(ParentNotificationFields.parentId, isEqualTo: _uid)
        .where(ParentNotificationFields.isRead, isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.set(doc.reference, {
        ParentNotificationFields.isRead: true,
        ParentNotificationFields.readAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------------
  // Live trip — joins students + trips + routes + busLocations
  // ---------------------------------------------------------------------

  @override
  Stream<ParentTripEntity?> watchLiveTrip() {
    return _firestore
        .collection(FirebaseCollections.students)
        .where('parentId', isEqualTo: _uid)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .asyncExpand((studentsSnapshot) {
      final assigned = studentsSnapshot.docs
          .map(StudentEntity.fromDoc)
          .where((s) => s.busId != null && s.busId!.isNotEmpty)
          .toList();

      if (assigned.isEmpty) return Stream<ParentTripEntity?>.value(null);

      final student = assigned.first;
      // Not filtered by status — a completed trip must keep showing an
      // "Arrived" summary until the *next* trip starts, not vanish back to
      // "not started" the instant it ends. This is what lets a parent see
      // across the whole day: morning pickup -> school, then later
      // school -> home, rather than only a snapshot of "right now."
      // The `trips` rule gates reads on `schoolId`, so it must be an
      // explicit filter here too — filtering by `busId` alone is rejected
      // outright by Firestore, not just empty.
      return _firestore
          .collection(FirebaseCollections.trips)
          .where('schoolId', isEqualTo: student.schoolId)
          .where('busId', isEqualTo: student.busId)
          .limit(20)
          .snapshots()
          .asyncExpand((tripSnapshot) {
        final trip = _mostRelevantTrip(tripSnapshot.docs.map(TripEntity.fromDoc).toList());
        if (trip == null) {
          return Stream<ParentTripEntity?>.value(_notStartedTrip(student));
        }

        return _firestore
            .collection(FirebaseCollections.busLocations)
            .doc(trip.busId)
            .snapshots()
            .asyncMap((locSnapshot) async {
          RouteEntity? route;
          if (trip.routeId.isNotEmpty) {
            final routeDoc =
                await _firestore.collection(FirebaseCollections.routes).doc(trip.routeId).get();
            if (routeDoc.exists) route = RouteEntity.fromDoc(routeDoc);
          }
          final location = locSnapshot.exists ? BusLocationEntity.fromDoc(locSnapshot) : null;
          return _buildTripEntity(student: student, trip: trip, route: route, location: location);
        });
      });
    });
  }

  /// Prefers whichever trip is currently in progress; otherwise the most
  /// recently started/completed one, so a finished trip's summary stays on
  /// screen (e.g. this morning's drop-off, while waiting for the afternoon
  /// pickup to start) instead of reverting to a blank "not started" state.
  TripEntity? _mostRelevantTrip(List<TripEntity> trips) {
    final inProgress = trips.where((t) => t.status == TripStatus.inProgress).toList()
      ..sort((a, b) => (b.startedAt ?? DateTime(0)).compareTo(a.startedAt ?? DateTime(0)));
    if (inProgress.isNotEmpty) return inProgress.first;

    final byRecency = trips.toList()
      ..sort((a, b) {
        final aTime = a.completedAt ?? a.startedAt ?? DateTime(0);
        final bTime = b.completedAt ?? b.startedAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
    return byRecency.isEmpty ? null : byRecency.first;
  }

  ParentTripEntity _notStartedTrip(StudentEntity student) {
    return ParentTripEntity(
      tripId: '',
      childName: student.name,
      schoolName: student.schoolId,
      grade: student.grade,
      busNumber: student.busNumber ?? 'Unassigned',
      driverName: student.driverName ?? 'Not assigned',
      currentStop: '--',
      nextStop: student.stopName ?? '--',
      eta: '--',
      stopsAway: 0,
      progress: 0,
      status: ParentTripStatus.notStarted,
      routeStops: const [],
      lastUpdatedLabel: 'Trip has not started yet',
    );
  }

  ParentTripEntity _buildTripEntity({
    required StudentEntity student,
    required TripEntity trip,
    RouteEntity? route,
    BusLocationEntity? location,
  }) {
    final stops = route?.stops ?? const [];
    final eta = (location != null && stops.isNotEmpty)
        ? EtaCalculator.estimate(busLat: location.lat, busLng: location.lng, stops: stops)
        : EtaEstimate.unknown;

    final isCompleted = trip.status == TripStatus.completed;

    // The driver explicitly marking a stop as passed is more trustworthy
    // than the GPS-proximity guess — prefer it once the driver has started
    // confirming stops; fall back to the GPS heuristic only before that.
    final confirmedStops = trip.stopsCompleted.toSet();
    final hasConfirmations = confirmedStops.isNotEmpty;
    var currentIndex = eta.nearestStopIndex;
    if (hasConfirmations) {
      final firstUnconfirmed = stops.indexWhere((s) => !confirmedStops.contains(s.name));
      currentIndex = firstUnconfirmed == -1 ? stops.length - 1 : firstUnconfirmed;
    }

    final routeStops = <ParentRouteStopEntity>[
      for (var i = 0; i < stops.length; i++)
        ParentRouteStopEntity(
          id: '$i',
          name: stops[i].name,
          position: i,
          status: isCompleted || confirmedStops.contains(stops[i].name) || (!hasConfirmations && i < currentIndex)
              ? ParentRouteStopStatus.completed
              : i == currentIndex
                  ? ParentRouteStopStatus.current
                  : ParentRouteStopStatus.upcoming,
        ),
    ];

    final hasCurrentIndex = currentIndex >= 0 && currentIndex < stops.length;
    final currentStopName = hasCurrentIndex ? stops[currentIndex].name : eta.currentStopName;
    final nextIndex = currentIndex + 1 < stops.length ? currentIndex + 1 : currentIndex;
    final nextStopName =
        hasCurrentIndex && nextIndex < stops.length ? stops[nextIndex].name : eta.nextStopName;
    final stopsAwayCount = !hasCurrentIndex
        ? eta.stopsAway
        : (stops.length - 1 - currentIndex).clamp(0, stops.length);

    return ParentTripEntity(
      tripId: trip.id,
      childName: student.name,
      schoolName: student.schoolId,
      grade: student.grade,
      busNumber: student.busNumber ?? 'Bus',
      driverName: student.driverName ?? 'Driver',
      currentStop: currentStopName,
      nextStop: nextStopName,
      eta: isCompleted ? 'Arrived' : eta.etaLabel,
      stopsAway: stopsAwayCount,
      progress: isCompleted
          ? 1.0
          : (stops.length <= 1 ? eta.progress : (currentIndex / (stops.length - 1)).clamp(0.0, 1.0)),
      status: isCompleted ? ParentTripStatus.completed : ParentTripStatus.onTime,
      routeStops: routeStops,
      busLatitude: location?.lat,
      busLongitude: location?.lng,
      lastUpdatedLabel: isCompleted
          ? 'Completed ${_formatWhen(trip.completedAt)}'
          : (location?.updatedAt != null ? 'Live now' : 'Waiting for GPS signal'),
      minutesAway: isCompleted ? -1 : eta.minutesAway,
      studentEvent: trip.studentEvents[student.id],
      tripType: trip.type,
    );
  }

  String _formatWhen(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final isToday = time.year == now.year && time.month == now.month && time.day == now.day;
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final clock = '$hour12:$minute $period';
    if (isToday) return clock;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[time.weekday - 1]} $clock';
  }
}
