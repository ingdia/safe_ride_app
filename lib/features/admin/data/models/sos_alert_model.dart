enum SosStatus { active, resolved }

extension SosStatusX on SosStatus {
  String get value {
    switch (this) {
      case SosStatus.active:
        return 'active';
      case SosStatus.resolved:
        return 'resolved';
    }
  }
}

class GeoPoint {
  final double lat;
  final double lng;

  const GeoPoint({required this.lat, required this.lng});
}

class SosAlertModel {
  final String sosId;
  final String triggeredBy;
  final String busId;
  final String routeId;
  final GeoPoint location;
  final SosStatus status;
  final DateTime timestamp;
  final String? resolvedBy;

  const SosAlertModel({
    required this.sosId,
    required this.triggeredBy,
    required this.busId,
    required this.routeId,
    required this.location,
    required this.status,
    required this.timestamp,
    this.resolvedBy,
  });
}
