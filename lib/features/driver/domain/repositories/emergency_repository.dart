import '../entities/emergency_alert.dart';

abstract class EmergencyRepository {
  /// Triggers an SOS alert for the current driver.
  /// Returns the created [EmergencyAlert] on success.
  /// Throws [EmergencyException] on failure.
  Future<EmergencyAlert> triggerSos({
    required String driverName,
    required String vehicle,
    required EmergencyType emergencyType,
  });

  /// Returns all active and recent emergency alerts (for admin/parent view).
  Future<List<EmergencyAlert>> fetchAlerts();

  /// Marks an alert as acknowledged.
  Future<EmergencyAlert> acknowledgeAlert(String alertId);

  /// Marks an alert as resolved.
  Future<EmergencyAlert> resolveAlert(String alertId);
}
