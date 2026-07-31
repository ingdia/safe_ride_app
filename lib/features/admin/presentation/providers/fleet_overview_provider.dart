import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bus_model.dart';
import '../../data/models/route_model.dart';
import '../../data/models/user_model.dart';
import 'buses_provider.dart';
import 'users_provider.dart';
import 'routes_provider.dart';
import 'school_students_provider.dart';

enum FleetBusStatus { onTime, delayed }

class FleetBusSummary {
  final String busId;
  final String plateNumber;
  final String driverName;
  final int studentCount;
  final int capacity;
  final String routeName;
  final FleetBusStatus status;
  final String? statusNote;

  const FleetBusSummary({
    required this.busId,
    required this.plateNumber,
    required this.driverName,
    required this.studentCount,
    required this.capacity,
    required this.routeName,
    required this.status,
    this.statusNote,
  });
}

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
  final users = ref.watch(driversProvider);
  final routes = ref.watch(routesProvider);
  final students = ref
      .watch(schoolStudentsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const []);

  int studentCountFor(String busId) =>
      students.where((s) => s.isApproved && s.busId == busId).length;

  final summaries = <FleetBusSummary>[];
  final assignedBusIds = <String>{};

  for (final RouteModel route in routes) {
    final bus = _findBus(buses, route.busId);
    if (bus == null) continue;
    final driver = _findDriver(users, bus.driverId);
    assignedBusIds.add(bus.busId);

    summaries.add(
      FleetBusSummary(
        busId: bus.busId,
        plateNumber: bus.plateNumber,
        driverName: driver?.name ?? 'Unassigned',
        studentCount: studentCountFor(bus.busId),
        capacity: bus.capacity,
        routeName: route.name,
        status: FleetBusStatus.onTime,
      ),
    );
  }

  // Buses with no route yet (e.g. just created via BusFormSheet) still show
  // up here instead of silently disappearing from Active Fleet, since
  // BusFormSheet doesn't currently collect a route assignment.
  for (final bus in buses) {
    if (assignedBusIds.contains(bus.busId)) continue;
    final driver = _findDriver(users, bus.driverId);
    summaries.add(
      FleetBusSummary(
        busId: bus.busId,
        plateNumber: bus.plateNumber,
        driverName: driver?.name ?? 'Unassigned',
        studentCount: studentCountFor(bus.busId),
        capacity: bus.capacity,
        routeName: 'No route assigned',
        status: FleetBusStatus.onTime,
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

// Previously hardcoded (22 / 465 / 94%), so the stat cards never reflected
// real add/edit/delete activity. Now derived from fleetSummaryProvider so
// adding or removing a bus actually moves these numbers.
final fleetStatsProvider = Provider<FleetStats>((ref) {
  final summaries = ref.watch(fleetSummaryProvider);

  final activeBuses = summaries.length;
  final totalStudents = summaries.fold<int>(
    0,
    (sum, s) => sum + s.studentCount,
  );

  final onTimeCount = summaries
      .where((s) => s.status == FleetBusStatus.onTime)
      .length;
  final onTimePercent = summaries.isEmpty
      ? 100
      : ((onTimeCount / summaries.length) * 100).round();

  return FleetStats(
    activeBuses: activeBuses,
    totalStudents: totalStudents,
    onTimePercent: onTimePercent,
  );
});
