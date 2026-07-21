enum EmergencyType { accident, breakdown, medical, security, other }

enum EmergencyStatus { active, acknowledged, resolved }

class EmergencyAlert {
  const EmergencyAlert({
    required this.id,
    required this.driverName,
    required this.vehicle,
    required this.emergencyType,
    required this.status,
    required this.location,
    required this.triggeredAt,
    this.resolvedAt,
  });

  final String id;
  final String driverName;
  final String vehicle;
  final EmergencyType emergencyType;
  final EmergencyStatus status;
  final String location;
  final DateTime triggeredAt;
  final DateTime? resolvedAt;
}
