import '../models/driver_model.dart';

class DriversRepository {
  final List<DriverModel> _drivers = [
    DriverModel(
      driverId: 'drv-001',
      name: 'James Okafor',
      email: 'james.okafor@example.com',
      phone: '+250 788 123 456',
      licenseNumber: 'RWA-LIC-88213',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DriverModel(
      driverId: 'drv-002',
      name: 'Grace Uwase',
      email: 'grace.uwase@example.com',
      phone: '+250 788 555 210',
      licenseNumber: 'RWA-LIC-77410',
      submittedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  List<DriverModel> fetchDrivers() => List.unmodifiable(_drivers);

  void updateStatus(String driverId, DriverApprovalStatus status) {
    final index = _drivers.indexWhere((d) => d.driverId == driverId);
    if (index != -1) {
      _drivers[index] = _drivers[index].copyWith(status: status);
    }
  }
}
