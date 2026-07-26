import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/parent_trip_entity.dart';

class ParentTripFirestoreModel {
  const ParentTripFirestoreModel._();

  static ParentTripEntity fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    if (data == null) {
      return fallback(snapshot.id);
    }

    return ParentTripEntity(
      tripId: snapshot.id,
      childName: _readString(data, 'childName', 'Ineza Uwase'),
      schoolName: _readString(data, 'schoolName', 'Kigali Parents School'),
      grade: _readString(data, 'grade', 'Primary 4'),
      busNumber: _readString(data, 'busNumber', 'Bus #12'),
      driverName: _readString(data, 'driverName', 'Jean Bosco'),
      currentStop: _readString(data, 'currentStop', 'Remera'),
      nextStop: _readString(data, 'nextStop', 'Giporoso'),
      eta: _readString(data, 'eta', '8:15 AM'),
      stopsAway: _readInt(data, 'stopsAway', 4),
      progress: _readDouble(data, 'progress', 0.42),
      status: _statusFromString(_readString(data, 'status', 'onTime')),
      routeStops: _routeStopsFromData(data['routeStops']),
    );
  }

  static ParentTripEntity fallback(String tripId) {
    return ParentTripEntity(
      tripId: tripId,
      childName: 'Ineza Uwase',
      schoolName: 'Kigali Parents School',
      grade: 'Primary 4',
      busNumber: 'Bus #12',
      driverName: 'Jean Bosco',
      currentStop: 'Remera',
      nextStop: 'Giporoso',
      eta: '8:15 AM',
      stopsAway: 4,
      progress: 0.42,
      status: ParentTripStatus.onTime,
      routeStops: const [
        ParentRouteStopEntity(
          id: 'stop_001',
          name: 'Kacyiru',
          time: '3 students',
          status: ParentRouteStopStatus.completed,
          position: 1,
        ),
        ParentRouteStopEntity(
          id: 'stop_002',
          name: 'Gishushu',
          time: '2 students',
          status: ParentRouteStopStatus.completed,
          position: 2,
        ),
        ParentRouteStopEntity(
          id: 'stop_003',
          name: 'Remera',
          time: '4 students',
          status: ParentRouteStopStatus.current,
          position: 3,
        ),
        ParentRouteStopEntity(
          id: 'stop_004',
          name: 'Giporoso',
          time: '2 students',
          status: ParentRouteStopStatus.upcoming,
          position: 4,
        ),
        ParentRouteStopEntity(
          id: 'stop_005',
          name: 'Kimironko',
          time: '3 students',
          status: ParentRouteStopStatus.upcoming,
          position: 5,
        ),
        ParentRouteStopEntity(
          id: 'stop_006',
          name: 'Kibagabaga',
          time: '2 students',
          status: ParentRouteStopStatus.upcoming,
          position: 6,
        ),
        ParentRouteStopEntity(
          id: 'stop_007',
          name: 'Kigali Parents School',
          time: 'School arrival',
          status: ParentRouteStopStatus.upcoming,
          position: 7,
        ),
      ],
    );
  }

  static List<ParentRouteStopEntity> _routeStopsFromData(Object? rawStops) {
    if (rawStops is! List) {
      return fallback('trip_001').routeStops;
    }

    return rawStops.asMap().entries.map((entry) {
      final index = entry.key;
      final rawStop = entry.value;

      if (rawStop is! Map<String, dynamic>) {
        return ParentRouteStopEntity(
          id: 'stop_$index',
          name: 'Unknown stop',
          time: '',
          status: ParentRouteStopStatus.upcoming,
          position: index + 1,
        );
      }

      return ParentRouteStopEntity(
        id: _readString(rawStop, 'id', 'stop_$index'),
        name: _readString(rawStop, 'name', 'Unknown stop'),
        time: _readString(rawStop, 'time', ''),
        status: _routeStopStatusFromString(
          _readString(rawStop, 'status', 'upcoming'),
        ),
        position: _readInt(rawStop, 'position', index + 1),
      );
    }).toList();
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, [
    String fallbackValue = '',
  ]) {
    final value = data[key];

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return fallbackValue;
  }

  static int _readInt(
    Map<String, dynamic> data,
    String key,
    int fallbackValue,
  ) {
    final value = data[key];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return fallbackValue;
  }

  static double _readDouble(
    Map<String, dynamic> data,
    String key,
    double fallbackValue,
  ) {
    final value = data[key];

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return fallbackValue;
  }

  static ParentTripStatus _statusFromString(String status) {
    switch (status) {
      case 'delayed':
        return ParentTripStatus.delayed;
      case 'completed':
        return ParentTripStatus.completed;
      case 'emergency':
        return ParentTripStatus.emergency;
      case 'onTime':
      default:
        return ParentTripStatus.onTime;
    }
  }

  static ParentRouteStopStatus _routeStopStatusFromString(String status) {
    switch (status) {
      case 'completed':
        return ParentRouteStopStatus.completed;
      case 'current':
        return ParentRouteStopStatus.current;
      case 'upcoming':
      default:
        return ParentRouteStopStatus.upcoming;
    }
  }
}
