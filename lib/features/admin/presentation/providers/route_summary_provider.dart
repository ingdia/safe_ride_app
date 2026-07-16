import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'buses_provider.dart';
import 'routes_provider.dart';

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

final Map<String, String> _backupBusIdByRouteId = {
  'route-a': 'bus-08',
  'route-c': 'bus-19',
};

final Map<String, int> _mockDurationMinutes = {
  'route-a': 45,
  'route-b': 40,
  'route-c': 55,
  'route-d': 35,
};

final Map<String, int> _mockRouteStudentCounts = {
  'route-a': 38,
  'route-b': 22,
  'route-c': 46,
  'route-d': 16,
};

final routeSummaryProvider = Provider<List<RouteSummary>>((ref) {
  final routes = ref.watch(routesProvider);
  final buses = ref.watch(busesProvider);

  return routes.map((route) {
    final primaryBus = buses.firstWhere((b) => b.busId == route.busId);
    final backupBusId = _backupBusIdByRouteId[route.routeId];
    final plateNumbers = [primaryBus.plateNumber];
    if (backupBusId != null) {
      final backupBus = buses.firstWhere((b) => b.busId == backupBusId);
      plateNumbers.add(backupBus.plateNumber);
    }

    return RouteSummary(
      routeId: route.routeId,
      name: route.name,
      busPlateNumbers: plateNumbers,
      stopCount: route.stops.length,
      durationMinutes: _mockDurationMinutes[route.routeId] ?? 0,
      studentCount: _mockRouteStudentCounts[route.routeId] ?? 0,
    );
  }).toList();
});
