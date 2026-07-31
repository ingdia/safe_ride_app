import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../domain/entities/parent_trip_entity.dart';
import '../providers/parent_data_providers.dart';
import '../widgets/parent_ui_constants.dart';

class ParentTrackingScreen extends ConsumerWidget {
  const ParentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(parentLiveTripStreamProvider);

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: tripState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Unable to load live tracking.\n$error', textAlign: TextAlign.center),
          ),
          data: (trip) {
            if (trip == null) {
              return const _NoApprovedChildState();
            }
            return _TrackingContent(trip: trip);
          },
        ),
      ),
    );
  }
}

class _NoApprovedChildState extends StatelessWidget {
  const _NoApprovedChildState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 48, color: ParentUiColors.orange),
            const SizedBox(height: 16),
            const Text(
              'Nothing to track yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Live tracking appears once the school approves your child.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingContent extends StatelessWidget {
  const _TrackingContent({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          _TrackingHeader(trip: trip),
          const SizedBox(height: 18),
          _LiveMapCard(trip: trip),
          const SizedBox(height: 18),
          _CurrentTripCard(trip: trip),
          const SizedBox(height: 18),
          if (trip.routeStops.isNotEmpty) _RouteStopsCard(stops: trip.routeStops),
        ],
      ),
    );
  }
}

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: ParentUiColors.orange,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Map',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Real-time tracking for ${trip.busNumber}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trip.legLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 10, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  trip.lastUpdatedLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveMapCard extends StatelessWidget {
  const _LiveMapCard({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    final hasLocation = trip.busLatitude != null && trip.busLongitude != null;
    final busPoint = hasLocation
        ? latlong.LatLng(trip.busLatitude!, trip.busLongitude!)
        : const latlong.LatLng(0, 0);

    return _SectionCard(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: hasLocation
                  ? FlutterMap(
                      options: MapOptions(initialCenter: busPoint, initialZoom: 14),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.saferide.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: busPoint,
                              width: 44,
                              height: 44,
                              child: const Icon(
                                Icons.directions_bus_filled,
                                color: ParentUiColors.orange,
                                size: 34,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      color: ParentUiColors.orange.withValues(alpha: 0.08),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gps_not_fixed, size: 42, color: ParentUiColors.orange),
                          const SizedBox(height: 8),
                          Text(
                            trip.status == ParentTripStatus.notStarted
                                ? 'Trip has not started yet'
                                : 'Waiting for GPS signal…',
                            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentTripCard extends StatelessWidget {
  const _CurrentTripCard({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Trip',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _TripInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Current stop',
            value: trip.currentStop,
          ),
          const SizedBox(height: 12),
          _TripInfoRow(
            icon: Icons.near_me_outlined,
            title: 'Next stop',
            value: trip.nextStop,
          ),
          const SizedBox(height: 12),
          _TripInfoRow(icon: Icons.access_time, title: 'ETA', value: trip.eta),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: trip.progress.clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: ParentUiColors.orange.withValues(alpha: 0.16),
          ),
          const SizedBox(height: 8),
          Text(
            '${trip.stopsAway} stops away',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStopsCard extends StatelessWidget {
  const _RouteStopsCard({required this.stops});

  final List<ParentRouteStopEntity> stops;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Route Stops',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final stop in stops) _RouteStopRow(stop: stop),
        ],
      ),
    );
  }
}

class _RouteStopRow extends StatelessWidget {
  const _RouteStopRow({required this.stop});

  final ParentRouteStopEntity stop;

  @override
  Widget build(BuildContext context) {
    final isCurrent = stop.status == ParentRouteStopStatus.current;
    final isCompleted = stop.status == ParentRouteStopStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent
            ? ParentUiColors.orange.withValues(alpha: 0.08)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? ParentUiColors.orange
              : Colors.grey.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isCompleted ? Colors.green : ParentUiColors.orange,
            child: Icon(
              isCompleted ? Icons.check : Icons.location_on,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stop.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          Text(
            _statusLabel(stop.status),
            style: TextStyle(
              color: isCurrent ? ParentUiColors.orange : Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(ParentRouteStopStatus status) {
    switch (status) {
      case ParentRouteStopStatus.completed:
        return 'Completed';
      case ParentRouteStopStatus.current:
        return 'Current';
      case ParentRouteStopStatus.upcoming:
        return 'Upcoming';
    }
  }
}

class _TripInfoRow extends StatelessWidget {
  const _TripInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ParentUiColors.orange),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
