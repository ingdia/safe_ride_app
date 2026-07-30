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

  factory RouteStop.fromMap(Map<String, dynamic> map) => RouteStop(
        name: map['name'] as String? ?? '',
        lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
        order: (map['order'] as num?)?.toInt() ?? 0,
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
  final DateTime createdAt;
  /// Scheduled arrival time in HH:mm format, e.g. "08:15". Empty if not set.
  final String scheduledArrivalTime;

  const RouteModel({
    required this.routeId,
    required this.schoolId,
    required this.busId,
    required this.name,
    this.stops = const [],
    required this.createdAt,
    this.scheduledArrivalTime = '',
  });

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawStops = data['stops'] as List<dynamic>? ?? [];
    return RouteModel(
      routeId: doc.id,
      schoolId: data['school_id'] as String? ?? '',
      busId: data['bus_id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      stops: rawStops
          .map((s) => RouteStop.fromMap(s as Map<String, dynamic>))
          .toList(),
      createdAt:
          (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledArrivalTime:
          data['scheduled_arrival_time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'school_id': schoolId,
        'bus_id': busId,
        'name': name,
        'stops': stops.map((s) => s.toMap()).toList(),
        'created_at': Timestamp.fromDate(createdAt),
        'scheduled_arrival_time': scheduledArrivalTime,
      };

  RouteModel copyWith({
    String? name,
    String? busId,
    List<RouteStop>? stops,
    String? scheduledArrivalTime,
  }) {
    return RouteModel(
      routeId: routeId,
      schoolId: schoolId,
      busId: busId ?? this.busId,
      name: name ?? this.name,
      stops: stops ?? this.stops,
      createdAt: createdAt,
      scheduledArrivalTime:
          scheduledArrivalTime ?? this.scheduledArrivalTime,
    );
  }
}
