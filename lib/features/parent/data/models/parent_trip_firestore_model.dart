import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/parent_trip_entity.dart';
import '../datasources/parent_firestore_fields.dart';

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
      childName: _readString(data, ParentTripFields.childName, 'Ineza Uwase'),
      schoolName: _readString(
        data,
        ParentTripFields.schoolName,
        'Kigali Parents School',
      ),
      grade: _readString(data, ParentTripFields.grade, 'Primary 4'),
      busNumber: _readString(data, ParentTripFields.busNumber, 'Bus #12'),
      driverName: _readString(data, ParentTripFields.driverName, 'Jean Bosco'),
      currentStop: _readString(data, ParentTripFields.currentStop, 'Remera'),
      nextStop: _readString(data, ParentTripFields.nextStop, 'Giporoso'),
      eta: _readString(data, ParentTripFields.eta, '8:15 AM'),
      stopsAway: _readInt(data, ParentTripFields.stopsAway, 4),
      progress: _readDouble(data, ParentTripFields.progress, 0.42),
      status: _statusFromString(
        _readString(data, ParentTripFields.status, 'onTime'),
      ),
      routeStops: _routeStopsFromData(data[ParentTripFields.routeStops]),
      busLatitude: _readLatitude(data),
      busLongitude: _readLongitude(data),
      lastUpdatedLabel: _readLastUpdatedLabel(
        data[ParentTripFields.lastUpdatedAt],
      ),
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
      busLatitude: -1.9441,
      busLongitude: 30.0619,
      lastUpdatedLabel: 'Live now',
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
        id: _readString(rawStop, ParentTripFields.stopId, 'stop_$index'),
        name: _readString(rawStop, ParentTripFields.stopName, 'Unknown stop'),
        time: _readString(rawStop, ParentTripFields.stopTime, ''),
        status: _routeStopStatusFromString(
          _readString(rawStop, ParentTripFields.status, 'upcoming'),
        ),
        position: _readInt(rawStop, ParentTripFields.stopPosition, index + 1),
      );
    }).toList();
  }

  static double _readLatitude(Map<String, dynamic> data) {
    final location = data[ParentTripFields.busLocation];

    if (location is GeoPoint) {
      return location.latitude;
    }

    if (location is Map<String, dynamic>) {
      final value = location[ParentTripFields.latitude];

      if (value is num) {
        return value.toDouble();
      }
    }

    return _readDouble(data, ParentTripFields.latitude, -1.9441);
  }

  static double _readLongitude(Map<String, dynamic> data) {
    final location = data[ParentTripFields.busLocation];

    if (location is GeoPoint) {
      return location.longitude;
    }

    if (location is Map<String, dynamic>) {
      final value = location[ParentTripFields.longitude];

      if (value is num) {
        return value.toDouble();
      }
    }

    return _readDouble(data, ParentTripFields.longitude, 30.0619);
  }

  static String _readLastUpdatedLabel(Object? value) {
    if (value is Timestamp) {
      final updatedAt = value.toDate();
      final difference = DateTime.now().difference(updatedAt);

      if (difference.inMinutes < 1) {
        return 'Live now';
      }

      if (difference.inMinutes < 60) {
        return 'Updated ${difference.inMinutes} min ago';
      }

      return 'Updated ${difference.inHours} hr ago';
    }

    return 'Live now';
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
