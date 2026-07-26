import 'package:cloud_firestore/cloud_firestore.dart';

import 'parent_firestore_fields.dart';
import 'parent_firestore_paths.dart';

class ParentDemoTripSeed {
  ParentDemoTripSeed({FirebaseFirestore? firestore, this.tripId = 'trip_001'})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String tripId;

  Future<void> saveDemoTrip() async {
    await _firestore.collection(ParentFirestorePaths.trips).doc(tripId).set({
      ParentTripFields.childName: 'Ineza Uwase',
      ParentTripFields.schoolName: 'Kigali Parents School',
      ParentTripFields.grade: 'Primary 4',
      ParentTripFields.busNumber: 'Bus #12',
      ParentTripFields.driverName: 'Jean Bosco',
      ParentTripFields.currentStop: 'Remera',
      ParentTripFields.nextStop: 'Giporoso',
      ParentTripFields.eta: '8:15 AM',
      ParentTripFields.stopsAway: 4,
      ParentTripFields.progress: 0.42,
      ParentTripFields.status: 'onTime',
      ParentTripFields.busLocation: {
        ParentTripFields.latitude: -1.9565,
        ParentTripFields.longitude: 30.1044,
      },
      ParentTripFields.lastUpdatedAt: FieldValue.serverTimestamp(),
      ParentTripFields.routeStops: _initialRouteStops(),
    });
  }

  Future<void> moveBusToNextStop() async {
    await _firestore.collection(ParentFirestorePaths.trips).doc(tripId).update({
      ParentTripFields.currentStop: 'Giporoso',
      ParentTripFields.nextStop: 'Kimironko',
      ParentTripFields.eta: '8:20 AM',
      ParentTripFields.stopsAway: 3,
      ParentTripFields.progress: 0.58,
      ParentTripFields.status: 'onTime',
      ParentTripFields.busLocation: {
        ParentTripFields.latitude: -1.9482,
        ParentTripFields.longitude: 30.1269,
      },
      ParentTripFields.lastUpdatedAt: FieldValue.serverTimestamp(),
      ParentTripFields.routeStops: _movedRouteStops(),
    });
  }

  Future<void> markTripDelayed() async {
    await _firestore.collection(ParentFirestorePaths.trips).doc(tripId).update({
      ParentTripFields.status: 'delayed',
      ParentTripFields.eta: '8:28 AM',
      ParentTripFields.lastUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> markTripCompleted() async {
    await _firestore.collection(ParentFirestorePaths.trips).doc(tripId).update({
      ParentTripFields.status: 'completed',
      ParentTripFields.currentStop: 'Kigali Parents School',
      ParentTripFields.nextStop: 'Arrived',
      ParentTripFields.eta: 'Arrived',
      ParentTripFields.stopsAway: 0,
      ParentTripFields.progress: 1.0,
      ParentTripFields.busLocation: {
        ParentTripFields.latitude: -1.9351,
        ParentTripFields.longitude: 30.0986,
      },
      ParentTripFields.lastUpdatedAt: FieldValue.serverTimestamp(),
      ParentTripFields.routeStops: _completedRouteStops(),
    });
  }

  List<Map<String, Object>> _initialRouteStops() {
    return [
      _routeStop(
        id: 'stop_001',
        name: 'Kacyiru',
        time: '3 students',
        status: 'completed',
        position: 1,
      ),
      _routeStop(
        id: 'stop_002',
        name: 'Gishushu',
        time: '2 students',
        status: 'completed',
        position: 2,
      ),
      _routeStop(
        id: 'stop_003',
        name: 'Remera',
        time: '4 students',
        status: 'current',
        position: 3,
      ),
      _routeStop(
        id: 'stop_004',
        name: 'Giporoso',
        time: '2 students',
        status: 'upcoming',
        position: 4,
      ),
      _routeStop(
        id: 'stop_005',
        name: 'Kimironko',
        time: '3 students',
        status: 'upcoming',
        position: 5,
      ),
      _routeStop(
        id: 'stop_006',
        name: 'Kibagabaga',
        time: '2 students',
        status: 'upcoming',
        position: 6,
      ),
      _routeStop(
        id: 'stop_007',
        name: 'Kigali Parents School',
        time: 'School arrival',
        status: 'upcoming',
        position: 7,
      ),
    ];
  }

  List<Map<String, Object>> _movedRouteStops() {
    return [
      _routeStop(
        id: 'stop_001',
        name: 'Kacyiru',
        time: '3 students',
        status: 'completed',
        position: 1,
      ),
      _routeStop(
        id: 'stop_002',
        name: 'Gishushu',
        time: '2 students',
        status: 'completed',
        position: 2,
      ),
      _routeStop(
        id: 'stop_003',
        name: 'Remera',
        time: '4 students',
        status: 'completed',
        position: 3,
      ),
      _routeStop(
        id: 'stop_004',
        name: 'Giporoso',
        time: '2 students',
        status: 'current',
        position: 4,
      ),
      _routeStop(
        id: 'stop_005',
        name: 'Kimironko',
        time: '3 students',
        status: 'upcoming',
        position: 5,
      ),
      _routeStop(
        id: 'stop_006',
        name: 'Kibagabaga',
        time: '2 students',
        status: 'upcoming',
        position: 6,
      ),
      _routeStop(
        id: 'stop_007',
        name: 'Kigali Parents School',
        time: 'School arrival',
        status: 'upcoming',
        position: 7,
      ),
    ];
  }

  List<Map<String, Object>> _completedRouteStops() {
    return [
      _routeStop(
        id: 'stop_001',
        name: 'Kacyiru',
        time: '3 students',
        status: 'completed',
        position: 1,
      ),
      _routeStop(
        id: 'stop_002',
        name: 'Gishushu',
        time: '2 students',
        status: 'completed',
        position: 2,
      ),
      _routeStop(
        id: 'stop_003',
        name: 'Remera',
        time: '4 students',
        status: 'completed',
        position: 3,
      ),
      _routeStop(
        id: 'stop_004',
        name: 'Giporoso',
        time: '2 students',
        status: 'completed',
        position: 4,
      ),
      _routeStop(
        id: 'stop_005',
        name: 'Kimironko',
        time: '3 students',
        status: 'completed',
        position: 5,
      ),
      _routeStop(
        id: 'stop_006',
        name: 'Kibagabaga',
        time: '2 students',
        status: 'completed',
        position: 6,
      ),
      _routeStop(
        id: 'stop_007',
        name: 'Kigali Parents School',
        time: 'School arrival',
        status: 'completed',
        position: 7,
      ),
    ];
  }

  Map<String, Object> _routeStop({
    required String id,
    required String name,
    required String time,
    required String status,
    required int position,
  }) {
    return {
      ParentTripFields.stopId: id,
      ParentTripFields.stopName: name,
      ParentTripFields.stopTime: time,
      ParentTripFields.status: status,
      ParentTripFields.stopPosition: position,
    };
  }
}
