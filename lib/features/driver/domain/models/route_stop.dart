/// A single stop on a driver's route, sourced live from `DriverRepository`
/// (Firestore-backed; see [FirestoreDriverRepository]).
enum RouteStopStatus { completed, current, upcoming }

class RouteStop {
  const RouteStop({
    required this.order,
    required this.name,
    required this.studentCount,
    required this.time,
    required this.status,
    this.isDestination = false,
    this.lat,
    this.lng,
  });

  final int order;
  final String name;
  final int studentCount;
  final String time;
  final RouteStopStatus status;
  final bool isDestination;

  /// Null when the admin created this stop without coordinates (e.g. via an
  /// older route entry) — callers must handle that rather than assume every
  /// stop is mappable.
  final double? lat;
  final double? lng;
}