import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bus_model.dart';
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

BusModel? _findBus(List<BusModel> buses, String busId) {
  for (final bus in buses) {
    if (bus.busId == busId) return bus;
  }
  return null;
}

final routeSummaryProvider = Provider<List<RouteSummary>>((ref) {
  final routes = ref.watch(routesProvider);
  final buses = ref.watch(busesProvider);

  return routes.map((route) {
    // A route's assigned bus can be deleted from Fleet Overview without the
    // route itself being cleaned up, so the lookup must tolerate a missing
    // bus instead of crashing (previously used firstWhere with no orElse).
    final primaryBus = _findBus(buses, route.busId);
    final backupBusId = _backupBusIdByRouteId[route.routeId];

    final plateNumbers = <String>[primaryBus?.plateNumber ?? 'Unassigned'];
    if (backupBusId != null) {
      final backupBus = _findBus(buses, backupBusId);
      plateNumbers.add(backupBus?.plateNumber ?? 'Unassigned');
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
