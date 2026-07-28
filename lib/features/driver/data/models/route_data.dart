import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/route_stop.dart';

/// Operational status of a route as stored in Firestore.
enum RouteStatus {
  /// Route has not started yet.
  scheduled,

  /// Driver is actively running the route.
  inProgress,

  /// All stops completed and students delivered.
  completed,

  /// Route was cancelled before completion.
  cancelled,
}

/// Full data model for a `routes/{routeId}` Firestore document.
///
/// Parsed once at the data layer so the UI and notifiers never touch a raw
/// [DocumentSnapshot]. Use [RouteData.fromFirestore] to construct from a
/// snapshot and [toMap] to serialise back to a plain map (e.g. for tests or
/// local caching).
///
/// Firestore document shape:
/// ```json
/// {
///   "name":          "Route A – Kigali North",
///   "busId":         "bus_001",
///   "driverId":      "driver_001",
///   "status":        "scheduled" | "inProgress" | "completed" | "cancelled",
///   "etaMinutes":    12,
///   "scheduledTime": "07:45",
///   "stops": [
///     {
///       "order":        1,
///       "name":         "Oak Street",
///       "studentCount": 3,
///       "time":         "7:45 AM",
///       "status":       "upcoming" | "current" | "completed",
///       "isDestination": false
///     }
///   ]
/// }
/// ```
class RouteData {
  const RouteData({
    required this.routeId,
    required this.name,
    required this.busId,
    required this.driverId,
    required this.status,
    required this.stops,
    required this.scheduledTime,
    this.etaMinutes,
  });

  /// Firestore document ID.
  final String routeId;

  /// Human-readable route name, e.g. `"Route A – Kigali North"`.
  final String name;

  /// ID of the bus assigned to this route.
  final String busId;

  /// ID of the driver assigned to this route.
  final String driverId;

  /// Current operational status of the route.
  final RouteStatus status;

  /// Ordered list of stops on this route.
  final List<RouteStop> stops;

  /// Scheduled departure time as a display string, e.g. `"07:45"`.
  final String scheduledTime;

  /// Estimated minutes until the next stop, or `null` when not yet computed.
  final int? etaMinutes;

  // ── Firestore ─────────────────────────────────────────────────────────────

  /// Constructs a [RouteData] from a Firestore document snapshot.
  ///
  /// Missing or malformed fields fall back to safe defaults so a partial
  /// document never throws.
  factory RouteData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final rawStops = data['stops'];

    final stops = (rawStops is List)
        ? rawStops
            .whereType<Map<String, dynamic>>()
            .map(_stopFromMap)
            .toList()
        : <RouteStop>[];

    stops.sort((a, b) => a.order.compareTo(b.order));

    return RouteData(
      routeId: snapshot.id,
      name: (data['name'] as String?) ?? '',
      busId: (data['busId'] as String?) ?? '',
      driverId: (data['driverId'] as String?) ?? '',
      status: _statusFromString((data['status'] as String?) ?? ''),
      stops: stops,
      scheduledTime: (data['scheduledTime'] as String?) ?? '',
      etaMinutes: (data['etaMinutes'] as num?)?.toInt(),
    );
  }

  /// Serialises this model to a plain map suitable for Firestore writes or
  /// local caching.
  Map<String, dynamic> toMap() => {
        'name': name,
        'busId': busId,
        'driverId': driverId,
        'status': _statusToString(status),
        'stops': stops.map(_stopToMap).toList(),
        'scheduledTime': scheduledTime,
        if (etaMinutes != null) 'etaMinutes': etaMinutes,
      };

  /// Returns a copy with the supplied fields replaced.
  RouteData copyWith({
    String? name,
    String? busId,
    String? driverId,
    RouteStatus? status,
    List<RouteStop>? stops,
    String? scheduledTime,
    int? etaMinutes,
  }) {
    return RouteData(
      routeId: routeId,
      name: name ?? this.name,
      busId: busId ?? this.busId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      stops: stops ?? this.stops,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static RouteStop _stopFromMap(Map<String, dynamic> m) {
    final statusStr = (m['status'] as String?) ?? 'upcoming';
    final RouteStopStatus stopStatus;
    switch (statusStr) {
      case 'completed':
        stopStatus = RouteStopStatus.completed;
      case 'current':
        stopStatus = RouteStopStatus.current;
      default:
        stopStatus = RouteStopStatus.upcoming;
    }

    return RouteStop(
      order: (m['order'] as num?)?.toInt() ?? 0,
      name: (m['name'] as String?) ?? '',
      studentCount: (m['studentCount'] as num?)?.toInt() ?? 0,
      time: (m['time'] as String?) ?? '',
      status: stopStatus,
      isDestination: (m['isDestination'] as bool?) ?? false,
    );
  }

  static Map<String, dynamic> _stopToMap(RouteStop s) => {
        'order': s.order,
        'name': s.name,
        'studentCount': s.studentCount,
        'time': s.time,
        'status': _stopStatusToString(s.status),
        'isDestination': s.isDestination,
      };

  static String _stopStatusToString(RouteStopStatus s) {
    switch (s) {
      case RouteStopStatus.completed:
        return 'completed';
      case RouteStopStatus.current:
        return 'current';
      case RouteStopStatus.upcoming:
        return 'upcoming';
    }
  }

  static RouteStatus _statusFromString(String value) {
    switch (value) {
      case 'inProgress':
        return RouteStatus.inProgress;
      case 'completed':
        return RouteStatus.completed;
      case 'cancelled':
        return RouteStatus.cancelled;
      default:
        return RouteStatus.scheduled;
    }
  }

  static String _statusToString(RouteStatus s) {
    switch (s) {
      case RouteStatus.inProgress:
        return 'inProgress';
      case RouteStatus.completed:
        return 'completed';
      case RouteStatus.cancelled:
        return 'cancelled';
      case RouteStatus.scheduled:
        return 'scheduled';
    }
  }
}
