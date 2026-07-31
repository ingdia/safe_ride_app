import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bus_model.dart';
import 'buses_provider.dart';
import 'routes_provider.dart';
import 'school_students_provider.dart';

class RouteSummary {
  final String routeId;
  final String name;
  final List<String> busPlateNumbers;
  final int stopCount;
  final int durationMinutes;
  final int studentCount;

  const RouteSummary({
    required this.routeId,
    required this.name,
    required this.busPlateNumbers,
    required this.stopCount,
    required this.durationMinutes,
    required this.studentCount,
  });
}

BusModel? _findBus(List<BusModel> buses, String busId) {
  for (final bus in buses) {
    if (bus.busId == busId) return bus;
  }
  return null;
}

/// Rough duration estimate (no historical trip-timing data is collected
/// yet) — a few minutes per stop plus driving between them.
const int _minutesPerStop = 4;

final routeSummaryProvider = Provider<List<RouteSummary>>((ref) {
  final routes = ref.watch(routesProvider);
  final buses = ref.watch(busesProvider);
  final students = ref
      .watch(schoolStudentsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const []);

  return routes.map((route) {
    final primaryBus = _findBus(buses, route.busId);
    final studentCount =
        students.where((s) => s.isApproved && s.routeId == route.routeId).length;

    return RouteSummary(
      routeId: route.routeId,
      name: route.name,
      busPlateNumbers: [primaryBus?.plateNumber ?? 'Unassigned'],
      stopCount: route.stops.length,
      durationMinutes: route.stops.length * _minutesPerStop,
      studentCount: studentCount,
    );
  }).toList();
});
