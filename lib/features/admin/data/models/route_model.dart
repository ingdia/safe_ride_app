import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory RouteStop.fromMap(Map<String, dynamic> m) => RouteStop(
        name: m['name'] as String? ?? '',
        lat: (m['lat'] as num?)?.toDouble() ?? 0,
        lng: (m['lng'] as num?)?.toDouble() ?? 0,
        order: (m['order'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'lat': lat,
        'lng': lng,
        'order': order,
      };
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

  factory RouteModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final stopsRaw = d['stops'] as List<dynamic>? ?? [];
    final stops = stopsRaw
        .map((s) => RouteStop.fromMap(Map<String, dynamic>.from(s as Map)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return RouteModel(
      routeId: doc.id,
      schoolId: d['schoolId'] as String? ?? '',
      busId: d['busId'] as String? ?? '',
      name: d['name'] as String? ?? '',
      stops: stops,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'schoolId': schoolId,
        'busId': busId,
        'name': name,
        'stops': stops.map((s) => s.toMap()).toList(),
      };

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
