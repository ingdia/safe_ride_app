class RouteStop {
  final String name;
  final double lat;
  final double lng;
  final int order;

  const RouteStop({
    required this.name,
    required this.lat,
    required this.lng,
    required this.order,
  });
}

class RouteModel {
  final String routeId;
  final String schoolId;
  final String busId;
  final String name;
  final List<RouteStop> stops;

  const RouteModel({
    required this.routeId,
    required this.schoolId,
    required this.busId,
    required this.name,
    this.stops = const [],
  });

  RouteModel copyWith({
    String? name,
    String? busId,
    List<RouteStop>? stops,
  }) {
    return RouteModel(
      routeId: routeId,
      schoolId: schoolId,
      busId: busId ?? this.busId,
      name: name ?? this.name,
      stops: stops ?? this.stops,
    );
  }
}
