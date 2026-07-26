import 'package:cloud_firestore/cloud_firestore.dart';

import 'parent_firestore_paths.dart';

class ParentDemoTripSeed {
  ParentDemoTripSeed({FirebaseFirestore? firestore, this.tripId = 'trip_001'})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String tripId;

  Future<void> saveDemoTrip() async {
    await _firestore.collection(ParentFirestorePaths.trips).doc(tripId).set({
      'childName': 'Ineza Uwase',
      'schoolName': 'Kigali Parents School',
      'grade': 'Primary 4',
      'busNumber': 'Bus #12',
      'driverName': 'Jean Bosco',
      'currentStop': 'Remera',
      'nextStop': 'Giporoso',
      'eta': '8:15 AM',
      'stopsAway': 4,
      'progress': 0.42,
      'status': 'onTime',
      'busLocation': {'latitude': -1.9565, 'longitude': 30.1044},
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      'routeStops': [
        {
          'id': 'stop_001',
          'name': 'Kacyiru',
          'time': '3 students',
          'status': 'completed',
          'position': 1,
        },
        {
          'id': 'stop_002',
          'name': 'Gishushu',
          'time': '2 students',
          'status': 'completed',
          'position': 2,
        },
        {
          'id': 'stop_003',
          'name': 'Remera',
          'time': '4 students',
          'status': 'current',
          'position': 3,
        },
        {
          'id': 'stop_004',
          'name': 'Giporoso',
          'time': '2 students',
          'status': 'upcoming',
          'position': 4,
        },
        {
          'id': 'stop_005',
          'name': 'Kimironko',
          'time': '3 students',
          'status': 'upcoming',
          'position': 5,
        },
        {
          'id': 'stop_006',
          'name': 'Kibagabaga',
          'time': '2 students',
          'status': 'upcoming',
          'position': 6,
        },
        {
          'id': 'stop_007',
          'name': 'Kigali Parents School',
          'time': 'School arrival',
          'status': 'upcoming',
          'position': 7,
        },
      ],
    });
  }

  Future<void> moveBusToNextStop() async {
    await _firestore.collection(ParentFirestorePaths.trips).doc(tripId).update({
      'currentStop': 'Giporoso',
      'nextStop': 'Kimironko',
      'eta': '8:20 AM',
      'stopsAway': 3,
      'progress': 0.58,
      'busLocation': {'latitude': -1.9482, 'longitude': 30.1269},
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      'routeStops': [
        {
          'id': 'stop_001',
          'name': 'Kacyiru',
          'time': '3 students',
          'status': 'completed',
          'position': 1,
        },
        {
          'id': 'stop_002',
          'name': 'Gishushu',
          'time': '2 students',
          'status': 'completed',
          'position': 2,
        },
        {
          'id': 'stop_003',
          'name': 'Remera',
          'time': '4 students',
          'status': 'completed',
          'position': 3,
        },
        {
          'id': 'stop_004',
          'name': 'Giporoso',
          'time': '2 students',
          'status': 'current',
          'position': 4,
        },
        {
          'id': 'stop_005',
          'name': 'Kimironko',
          'time': '3 students',
          'status': 'upcoming',
          'position': 5,
        },
        {
          'id': 'stop_006',
          'name': 'Kibagabaga',
          'time': '2 students',
          'status': 'upcoming',
          'position': 6,
        },
        {
          'id': 'stop_007',
          'name': 'Kigali Parents School',
          'time': 'School arrival',
          'status': 'upcoming',
          'position': 7,
        },
      ],
    });
  }
}
