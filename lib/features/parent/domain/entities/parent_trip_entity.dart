import '../../../../shared/models/trip_entity.dart' show TripType;

enum ParentTripStatus { notStarted, onTime, completed }

enum ParentRouteStopStatus { completed, current, upcoming }

class ParentRouteStopEntity {
  const ParentRouteStopEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.position,
  });

  final String id;
  final String name;
  final ParentRouteStopStatus status;
  final int position;
}

class ParentTripEntity {
  const ParentTripEntity({
    required this.tripId,
    required this.childName,
    required this.schoolName,
    required this.grade,
    required this.busNumber,
    required this.driverName,
    required this.currentStop,
    required this.nextStop,
    required this.eta,
    required this.stopsAway,
    required this.progress,
    required this.status,
    required this.routeStops,
    this.busLatitude,
    this.busLongitude,
    this.lastUpdatedLabel = 'Waiting for trip to start',
    this.minutesAway = -1,
    this.studentEvent,
    this.tripType,
  });

  final String tripId;
  final String childName;
  final String schoolName;
  final String grade;
  final String busNumber;
  final String driverName;
  final String currentStop;
  final String nextStop;
  final String eta;
  final int stopsAway;
  final double progress;
  final ParentTripStatus status;
  final List<ParentRouteStopEntity> routeStops;

  final double? busLatitude;
  final double? busLongitude;
  final String lastUpdatedLabel;

  /// Estimated minutes until the bus reaches the next stop, or -1 if
  /// unknown. Used to trigger the "bus approaching" notification.
  final int minutesAway;

  /// This child's own boarding event on the active trip: `'boarded'`,
  /// `'droppedOff'`, or `null` if neither has happened yet.
  final String? studentEvent;

  /// Morning (home -> school) or afternoon (school -> home) leg — null
  /// when there's no trip yet to classify.
  final TripType? tripType;

  bool get isLive => status == ParentTripStatus.onTime;

  String get statusLabel {
    switch (status) {
      case ParentTripStatus.notStarted:
        return 'Not Started';
      case ParentTripStatus.onTime:
        return 'On Time';
      case ParentTripStatus.completed:
        return 'Completed';
    }
  }

  String get legLabel {
    switch (tripType) {
      case TripType.morning:
        return 'Morning trip · Home to School';
      case TripType.afternoon:
        return 'Afternoon trip · School to Home';
      case null:
        return 'Today\'s trip';
    }
  }
}
