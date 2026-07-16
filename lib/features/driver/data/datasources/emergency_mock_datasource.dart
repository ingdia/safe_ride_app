import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/emergency_alert.dart';
import '../models/emergency_alert_model.dart';

/// Simulates a remote emergency data source with mocked data.
class EmergencyMockDatasource {
  // In-memory store so acknowledge/resolve mutations persist during the session
  final List<EmergencyAlertModel> _store = [
    EmergencyAlertModel(
      id: 'sos_001',
      driverName: 'Bob Driver',
      vehicle: 'KGL 204 B',
      emergencyType: EmergencyType.accident,
      status: EmergencyStatus.active,
      location: 'Kimironko, Kigali',
      triggeredAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    EmergencyAlertModel(
      id: 'sos_002',
      driverName: 'Jean Pierre',
      vehicle: 'KGL 117 A',
      emergencyType: EmergencyType.breakdown,
      status: EmergencyStatus.acknowledged,
      location: 'Remera, Kigali',
      triggeredAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 22)),
    ),
    EmergencyAlertModel(
      id: 'sos_003',
      driverName: 'Marie Claire',
      vehicle: 'KGL 089 C',
      emergencyType: EmergencyType.medical,
      status: EmergencyStatus.resolved,
      location: 'Kacyiru, Kigali',
      triggeredAt: DateTime.now().subtract(const Duration(hours: 3)),
      resolvedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
    ),
  ];

  Future<void> _delay([int ms = 900]) =>
      Future.delayed(Duration(milliseconds: ms));

  Future<EmergencyAlertModel> triggerSos({
    required String driverName,
    required String vehicle,
    required EmergencyType emergencyType,
  }) async {
    await _delay(1800);

    // Simulate a random failure ~10% of the time
    if (DateTime.now().millisecond % 10 == 0) {
      throw const EmergencyException(
        'Failed to send SOS. Check your connection and try again.',
      );
    }

    final alert = EmergencyAlertModel(
      id: 'sos_${DateTime.now().millisecondsSinceEpoch}',
      driverName: driverName,
      vehicle: vehicle,
      emergencyType: emergencyType,
      status: EmergencyStatus.active,
      location: 'Kigali, Rwanda (GPS mock)',
      triggeredAt: DateTime.now(),
    );

    _store.insert(0, alert);
    return alert;
  }

  Future<List<EmergencyAlertModel>> fetchAlerts() async {
    await _delay();
    return List.unmodifiable(_store);
  }

  Future<EmergencyAlertModel> acknowledgeAlert(String alertId) async {
    await _delay(600);
    final index = _store.indexWhere((a) => a.id == alertId);
    if (index == -1) {
      throw EmergencyException('Alert $alertId not found.');
    }
    final updated = _store[index].copyWithStatus(EmergencyStatus.acknowledged);
    _store[index] = updated;
    return updated;
  }

  Future<EmergencyAlertModel> resolveAlert(String alertId) async {
    await _delay(600);
    final index = _store.indexWhere((a) => a.id == alertId);
    if (index == -1) {
      throw EmergencyException('Alert $alertId not found.');
    }
    final updated = _store[index].copyWithStatus(EmergencyStatus.resolved);
    _store[index] = updated;
    return updated;
  }
}
