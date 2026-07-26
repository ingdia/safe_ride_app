enum ParentTripStatus { onTime, delayed, completed, emergency }

enum ParentRouteStopStatus { completed, current, upcoming }

class ParentRouteStopEntity {
  const ParentRouteStopEntity({
    required this.id,
    required this.name,
    required this.time,
    required this.status,
    required this.position,
  });

  final String id;
  final String name;
  final String time;
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
    this.busLatitude = -1.9441,
    this.busLongitude = 30.0619,
    this.lastUpdatedLabel = 'Live now',
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

  final double busLatitude;
  final double busLongitude;
  final String lastUpdatedLabel;

  bool get isOnTime {
    return status == ParentTripStatus.onTime;
  }

  String get statusLabel {
    switch (status) {
      case ParentTripStatus.onTime:
        return 'On Time';
      case ParentTripStatus.delayed:
        return 'Delayed';
      case ParentTripStatus.completed:
        return 'Completed';
      case ParentTripStatus.emergency:
        return 'Emergency';
    }
  }
}
