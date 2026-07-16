import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bus_model.dart';
import '../../data/models/route_model.dart';
import '../../data/models/user_model.dart';
import 'buses_provider.dart';
import 'users_provider.dart';
import 'routes_provider.dart';

enum FleetBusStatus { onTime, delayed }

class FleetBusSummary {
  final String busId;
  final String plateNumber;
  final String driverName;
  final int studentCount;
  final String routeName;
  final FleetBusStatus status;
  final String? statusNote;

  const FleetBusSummary({
    required this.busId,
    required this.plateNumber,
    required this.driverName,
    required this.studentCount,
    required this.routeName,
    required this.status,
    this.statusNote,
  });
}

final Map<String, int> _mockStudentCounts = {
  'bus-12': 18,
  'bus-07': 22,
  'bus-15': 20,
  'bus-03': 16,
};

final Map<String, FleetBusStatus> _mockStatuses = {
  'bus-12': FleetBusStatus.onTime,
  'bus-07': FleetBusStatus.delayed,
  'bus-15': FleetBusStatus.onTime,
  'bus-03': FleetBusStatus.onTime,
};

final Map<String, String> _mockStatusNotes = {'bus-07': 'Delayed by 8 minutes'};

BusModel? _findBus(List<BusModel> buses, String busId) {
  for (final bus in buses) {
    if (bus.busId == busId) return bus;
  }
  return null;
}

UserModel? _findDriver(List<UserModel> users, String driverId) {
  for (final user in users) {
    if (user.userId == driverId) return user;
  }
  return null;
}

final fleetSummaryProvider = Provider<List<FleetBusSummary>>((ref) {
  final buses = ref.watch(busesProvider);
  final users = ref.watch(usersProvider);
  final routes = ref.watch(routesProvider);

  final summaries = <FleetBusSummary>[];
  for (final RouteModel route in routes) {
    final bus = _findBus(buses, route.busId);
    if (bus == null) continue;
    final driver = _findDriver(users, bus.driverId);

    summaries.add(
      FleetBusSummary(
        busId: bus.busId,
        plateNumber: bus.plateNumber,
        driverName: driver?.name ?? 'Unassigned',
        studentCount: _mockStudentCounts[bus.busId] ?? 0,
        routeName: route.name,
        status: _mockStatuses[bus.busId] ?? FleetBusStatus.onTime,
        statusNote: _mockStatusNotes[bus.busId],
      ),
    );
  }
  return summaries;
});

class FleetStats {
  final int activeBuses;
  final int totalStudents;
  final int onTimePercent;

  const FleetStats({
    required this.activeBuses,
    required this.totalStudents,
    required this.onTimePercent,
  });
}

final fleetStatsProvider = Provider<FleetStats>((ref) {
  return const FleetStats(
    activeBuses: 22,
    totalStudents: 465,
    onTimePercent: 94,
  );
});
