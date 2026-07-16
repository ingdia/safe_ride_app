import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/emergency_alert.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_mock_datasource.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  EmergencyRepositoryImpl(this._datasource);

  final EmergencyMockDatasource _datasource;

  @override
  Future<EmergencyAlert> triggerSos({
    required String driverName,
    required String vehicle,
    required EmergencyType emergencyType,
  }) => _datasource.triggerSos(
        driverName: driverName,
        vehicle: vehicle,
        emergencyType: emergencyType,
      );

  @override
  Future<List<EmergencyAlert>> fetchAlerts() => _datasource.fetchAlerts();

  @override
  Future<EmergencyAlert> acknowledgeAlert(String alertId) =>
      _datasource.acknowledgeAlert(alertId);

  @override
  Future<EmergencyAlert> resolveAlert(String alertId) =>
      _datasource.resolveAlert(alertId);
}

final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (ref) => EmergencyRepositoryImpl(EmergencyMockDatasource()),
);
