import 'package:cloud_firestore/cloud_firestore.dart';

class RouteStopEntity {
  const RouteStopEntity({
    required this.name,
    required this.lat,
    required this.lng,
    required this.order,
  });

  final String name;
  final double lat;
  final double lng;
  final int order;

  factory RouteStopEntity.fromMap(Map<String, dynamic> m) => RouteStopEntity(
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

class RouteEntity {
  const RouteEntity({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.stops,
    this.busId,
  });

  final String id;
  final String schoolId;
  final String name;
  final String? busId;
  final List<RouteStopEntity> stops;

  factory RouteEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final stopsRaw = d['stops'] as List<dynamic>? ?? [];
    final stops = stopsRaw
        .map((s) => RouteStopEntity.fromMap(Map<String, dynamic>.from(s as Map)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return RouteEntity(
      id: doc.id,
      schoolId: d['schoolId'] as String? ?? '',
      name: d['name'] as String? ?? '',
      busId: d['busId'] as String?,
      stops: stops,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'schoolId': schoolId,
        'name': name,
        'busId': busId,
        'stops': stops.map((s) => s.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };
}
