import 'dart:math';

import '../../../../shared/models/route_entity.dart';

/// Client-side ETA estimate. This is a straight-line-distance heuristic
/// (assumed average road speed), not turn-by-turn routing — SafeRide avoids
/// any paid directions/maps API to stay on the Firebase Spark (free) plan.
class EtaEstimate {
  const EtaEstimate({
    required this.etaLabel,
    required this.minutesAway,
    required this.stopsAway,
    required this.progress,
    required this.currentStopName,
    required this.nextStopName,
    required this.nearestStopIndex,
  });

  final String etaLabel;
  final int minutesAway;
  final int stopsAway;
  final double progress;
  final String currentStopName;
  final String nextStopName;
  final int nearestStopIndex;

  static const EtaEstimate unknown = EtaEstimate(
    etaLabel: '--',
    minutesAway: -1,
    stopsAway: 0,
    progress: 0,
    currentStopName: 'Unknown',
    nextStopName: 'Unknown',
    nearestStopIndex: -1,
  );
}

class EtaCalculator {
  const EtaCalculator._();

  /// Assumed average speed for a school bus in mixed traffic.
  static const double assumedSpeedKmh = 25;

  static EtaEstimate estimate({
    required double busLat,
    required double busLng,
    required List<RouteStopEntity> stops,
  }) {
    if (stops.isEmpty) return EtaEstimate.unknown;

    var nearestIndex = 0;
    var nearestDistanceKm = double.infinity;
    for (var i = 0; i < stops.length; i++) {
      final d = _haversineKm(busLat, busLng, stops[i].lat, stops[i].lng);
      if (d < nearestDistanceKm) {
        nearestDistanceKm = d;
        nearestIndex = i;
      }
    }

    final nextIndex = nearestIndex + 1 < stops.length ? nearestIndex + 1 : nearestIndex;

    var remainingKm = _haversineKm(
      busLat,
      busLng,
      stops[nextIndex].lat,
      stops[nextIndex].lng,
    );
    for (var i = nextIndex; i < stops.length - 1; i++) {
      remainingKm += _haversineKm(
        stops[i].lat,
        stops[i].lng,
        stops[i + 1].lat,
        stops[i + 1].lng,
      );
    }

    final minutes = (remainingKm / assumedSpeedKmh * 60).round().clamp(0, 999);
    final etaTime = DateTime.now().add(Duration(minutes: minutes));
    final stopsAway = (stops.length - 1 - nearestIndex).clamp(0, stops.length);
    final progress = stops.length <= 1 ? 1.0 : nearestIndex / (stops.length - 1);

    return EtaEstimate(
      etaLabel: _formatClock(etaTime),
      minutesAway: minutes,
      stopsAway: stopsAway,
      progress: progress.clamp(0.0, 1.0),
      currentStopName: stops[nearestIndex].name,
      nextStopName: stops[nextIndex].name,
      nearestStopIndex: nearestIndex,
    );
  }

  static double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * pi / 180;

  static String _formatClock(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }
}
