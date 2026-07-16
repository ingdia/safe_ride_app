import '../models/bus_model.dart';

class BusesRepository {
  final List<BusModel> _buses = [
    const BusModel(
      busId: 'bus-12',
      plateNumber: '#12',
      capacity: 24,
      driverId: 'user-driver-12',
      schoolId: 'school-1',
    ),
    const BusModel(
      busId: 'bus-07',
      plateNumber: '#07',
      capacity: 24,
      driverId: 'user-driver-07',
      schoolId: 'school-1',
    ),
    const BusModel(
      busId: 'bus-15',
      plateNumber: '#15',
      capacity: 24,
      driverId: 'user-driver-15',
      schoolId: 'school-1',
    ),
    const BusModel(
      busId: 'bus-03',
      plateNumber: '#03',
      capacity: 24,
      driverId: 'user-driver-03',
      schoolId: 'school-1',
    ),
    const BusModel(
      busId: 'bus-08',
      plateNumber: '#08',
      capacity: 24,
      driverId: 'user-driver-12',
      schoolId: 'school-1',
    ),
    const BusModel(
      busId: 'bus-19',
      plateNumber: '#19',
      capacity: 24,
      driverId: 'user-driver-15',
      schoolId: 'school-1',
    ),
  ];

  List<BusModel> getAll() => List.unmodifiable(_buses);

  void add(BusModel bus) {
    _buses.add(bus);
  }

  void update(BusModel bus) {
    final index = _buses.indexWhere((b) => b.busId == bus.busId);
    if (index != -1) {
      _buses[index] = bus;
    }
  }

  void delete(String busId) {
    _buses.removeWhere((b) => b.busId == busId);
  }
}
