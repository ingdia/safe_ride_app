import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bus_model.dart';
import '../../data/models/student_model.dart';
import 'buses_provider.dart';
import 'routes_provider.dart';
import 'students_provider.dart';

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

final routeSummaryProvider = Provider<List<RouteSummary>>((ref) {
  final routes = ref.watch(routesListProvider);
  final buses = ref.watch(busesListProvider);
  final students = ref.watch(studentsListProvider);

  final studentsByRoute = <String, int>{};
  for (final StudentModel s in students) {
    studentsByRoute[s.routeId] = (studentsByRoute[s.routeId] ?? 0) + 1;
  }

  return routes.map((route) {
    final bus = _findBus(buses, route.busId);
    return RouteSummary(
      routeId: route.routeId,
      name: route.name,
      busPlateNumbers: [bus?.plateNumber ?? 'Unassigned'],
      stopCount: route.stops.length,
      durationMinutes: 0,
      studentCount: studentsByRoute[route.routeId] ?? 0,
    );
  }).toList();
});
