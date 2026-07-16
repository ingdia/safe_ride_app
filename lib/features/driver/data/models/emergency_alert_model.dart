import '../../domain/entities/emergency_alert.dart';

class EmergencyAlertModel extends EmergencyAlert {
  const EmergencyAlertModel({
    required super.id,
    required super.driverName,
    required super.vehicle,
    required super.emergencyType,
    required super.status,
    required super.location,
    required super.triggeredAt,
    super.resolvedAt,
  });

  factory EmergencyAlertModel.fromMap(Map<String, dynamic> map) {
    return EmergencyAlertModel(
      id: map['id'] as String,
      driverName: map['driverName'] as String,
      vehicle: map['vehicle'] as String,
      emergencyType: EmergencyType.values.byName(map['emergencyType'] as String),
      status: EmergencyStatus.values.byName(map['status'] as String),
      location: map['location'] as String,
      triggeredAt: DateTime.parse(map['triggeredAt'] as String),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'] as String)
          : null,
    );
  }

  EmergencyAlertModel copyWithStatus(EmergencyStatus newStatus) {
    return EmergencyAlertModel(
      id: id,
      driverName: driverName,
      vehicle: vehicle,
      emergencyType: emergencyType,
      status: newStatus,
      location: location,
      triggeredAt: triggeredAt,
      resolvedAt: newStatus == EmergencyStatus.resolved ? DateTime.now() : resolvedAt,
    );
  }
}
