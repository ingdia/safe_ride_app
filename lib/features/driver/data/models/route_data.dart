import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/route_stop.dart';

enum RouteStatus { scheduled, inProgress, completed, cancelled }

class RouteData {
  const RouteData({
    required this.routeId,
    required this.name,
    required this.busId,
    required this.driverId,
    required this.status,
    required this.scheduledTime,
    required this.etaMinutes,
    required this.stops,
  });

  final String routeId;
  final String name;
  final String busId;
  final String driverId;
  final RouteStatus status;
  final String scheduledTime;
  final int? etaMinutes;
  final List<RouteStop> stops;

  factory RouteData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final rawStops = data['stops'];

    return RouteData(
      routeId: snapshot.id,
      name: data['name'] as String? ?? '',
      busId: data['busId'] as String? ?? '',
      driverId: data['driverId'] as String? ?? '',
      status: _statusFromString(data['status'] as String? ?? ''),
      scheduledTime: data['scheduledTime'] as String? ?? '',
      etaMinutes: data['etaMinutes'] is int ? data['etaMinutes'] as int : null,
      stops: _parseStops(rawStops),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'busId': busId,
      'driverId': driverId,
      'status': status.name,
      'scheduledTime': scheduledTime,
      if (etaMinutes != null) 'etaMinutes': etaMinutes,
      'stops': stops.map(_stopToMap).toList(),
    };
  }

  RouteData copyWith({
    String? routeId,
    String? name,
    String? busId,
    String? driverId,
    RouteStatus? status,
    String? scheduledTime,
    int? etaMinutes,
    List<RouteStop>? stops,
  }) {
    return RouteData(
      routeId: routeId ?? this.routeId,
      name: name ?? this.name,
      busId: busId ?? this.busId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      stops: stops ?? this.stops,
    );
  }

  static RouteStatus _statusFromString(String value) {
    switch (value) {
      case 'inProgress':
        return RouteStatus.inProgress;
      case 'completed':
        return RouteStatus.completed;
      case 'cancelled':
        return RouteStatus.cancelled;
      case 'scheduled':
      default:
        return RouteStatus.scheduled;
    }
  }

  static List<RouteStop> _parseStops(Object? rawStops) {
    if (rawStops is List) {
      final stops = rawStops
          .whereType<Map<String, dynamic>>()
          .map(_stopFromMap)
          .toList();
      stops.sort((a, b) => a.order.compareTo(b.order));
      return stops;
    }
    return const [];
  }

  static RouteStop _stopFromMap(Map<String, dynamic> map) {
    return RouteStop(
      order: map['order'] is int ? map['order'] as int : 0,
      name: map['name'] as String? ?? '',
      studentCount: map['studentCount'] is int ? map['studentCount'] as int : 0,
      time: map['time'] as String? ?? '',
      status: _stopStatusFromString(map['status'] as String? ?? ''),
      isDestination: map['isDestination'] as bool? ?? false,
    );
  }

  static RouteStopStatus _stopStatusFromString(String value) {
    switch (value) {
      case 'completed':
        return RouteStopStatus.completed;
      case 'current':
        return RouteStopStatus.current;
      case 'upcoming':
      default:
        return RouteStopStatus.upcoming;
    }
  }

  static Map<String, dynamic> _stopToMap(RouteStop stop) {
    return {
      'order': stop.order,
      'name': stop.name,
      'studentCount': stop.studentCount,
      'time': stop.time,
      'status': stop.status.name,
      'isDestination': stop.isDestination,
    };
  }
}
