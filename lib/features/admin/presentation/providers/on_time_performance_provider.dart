import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/attendance_model.dart';
import '../../data/models/route_model.dart';
import 'attendance_provider.dart';
import 'routes_provider.dart';

const int _gracePeriodMinutes = 10;

class OnTimeDataPoint {
  final String date;
  final double onTimePercent;

  const OnTimeDataPoint({required this.date, required this.onTimePercent});
}

int? _parseMinutes(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}

final onTimePerformanceProvider = Provider<List<OnTimeDataPoint>>((ref) {
  final records = ref.watch(attendanceListProvider);
  final routes = ref.watch(routesListProvider);

  final scheduledByRoute = <String, int>{};
  for (final RouteModel route in routes) {
    final mins = _parseMinutes(route.scheduledArrivalTime);
    if (mins != null) scheduledByRoute[route.routeId] = mins;
  }

  if (scheduledByRoute.isEmpty) return [];

  // Latest alighted timestamp per (routeId, date)
  final latestAlighted = <String, DateTime>{};
  for (final AttendanceModel r in records) {
    if (r.status != AttendanceStatus.alighted) continue;
    if (!scheduledByRoute.containsKey(r.routeId)) continue;
    final key = '${r.routeId}|${r.date}';
    final existing = latestAlighted[key];
    if (existing == null || r.timestamp.isAfter(existing)) {
      latestAlighted[key] = r.timestamp;
    }
  }

  final onTimeByDate = <String, int>{};
  final totalByDate = <String, int>{};

  for (final entry in latestAlighted.entries) {
    final parts = entry.key.split('|');
    final routeId = parts[0];
    final date = parts[1];
    final scheduledMins = scheduledByRoute[routeId]!;
    final actual = entry.value;
    final actualMins = actual.hour * 60 + actual.minute;
    final isOnTime = (actualMins - scheduledMins) <= _gracePeriodMinutes;

    totalByDate[date] = (totalByDate[date] ?? 0) + 1;
    if (isOnTime) onTimeByDate[date] = (onTimeByDate[date] ?? 0) + 1;
  }

  final sortedDates = totalByDate.keys.toList()..sort();

  return sortedDates.map((date) {
    final total = totalByDate[date]!;
    final onTime = onTimeByDate[date] ?? 0;
    return OnTimeDataPoint(
      date: date,
      onTimePercent: (onTime / total) * 100,
    );
  }).toList();
});
