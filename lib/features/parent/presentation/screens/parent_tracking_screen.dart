import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          error: (error, stackTrace) =>
              _TrackingErrorState(message: error.toString()),
          data: (trip) => _TrackingContent(trip: trip),
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
          const _DemoTripActions(),
          const SizedBox(height: 18),
          _CurrentTripCard(trip: trip),
          const SizedBox(height: 18),
          _RouteStopsCard(stops: trip.routeStops),
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
    return _SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ParentUiColors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ParentUiColors.orange.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 96,
                      color: ParentUiColors.orange,
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  left: 22,
                  child: _MapBadge(
                    icon: Icons.directions_bus,
                    label: trip.busNumber,
                  ),
                ),
                Positioned(
                  bottom: 22,
                  right: 22,
                  child: Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: ParentUiColors.orange,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: ParentUiColors.orange.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_bus_filled,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LocationInfoTile(
                  title: 'Latitude',
                  value: trip.busLatitude.toStringAsFixed(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LocationInfoTile(
                  title: 'Longitude',
                  value: trip.busLongitude.toStringAsFixed(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoTripActions extends ConsumerWidget {
  const _DemoTripActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DemoActionButton(
                  icon: Icons.cloud_upload_outlined,
                  label: 'Seed Trip',
                  isFilled: true,
                  onPressed: () {
                    _runSeedAction(
                      context,
                      ref,
                      action: (seed) => seed.saveDemoTrip(),
                      successMessage: 'Demo trip saved to Firestore.',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DemoActionButton(
                  icon: Icons.directions_bus_outlined,
                  label: 'Move Bus',
                  onPressed: () {
                    _runSeedAction(
                      context,
                      ref,
                      action: (seed) => seed.moveBusToNextStop(),
                      successMessage: 'Bus location updated.',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DemoActionButton(
                  icon: Icons.warning_amber_outlined,
                  label: 'Delay',
                  onPressed: () {
                    _runSeedAction(
                      context,
                      ref,
                      action: (seed) => seed.markTripDelayed(),
                      successMessage: 'Trip marked as delayed.',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DemoActionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Complete',
                  onPressed: () {
                    _runSeedAction(
                      context,
                      ref,
                      action: (seed) => seed.markTripCompleted(),
                      successMessage: 'Trip marked as completed.',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _runSeedAction(
    BuildContext context,
    WidgetRef ref, {
    required Future<void> Function(dynamic seed) action,
    required String successMessage,
  }) async {
    final seed = ref.read(parentDemoTripSeedProvider);

    await action(seed);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
  }
}

class _DemoActionButton extends StatelessWidget {
  const _DemoActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isFilled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    if (isFilled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: ParentUiColors.orange,
          foregroundColor: Colors.white,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: ParentUiColors.orange,
        side: const BorderSide(color: ParentUiColors.orange),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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

class _LocationInfoTile extends StatelessWidget {
  const _LocationInfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
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

class _MapBadge extends StatelessWidget {
  const _MapBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, color: ParentUiColors.orange, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, required this.margin});

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
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

class _TrackingErrorState extends StatelessWidget {
  const _TrackingErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Unable to load live tracking.\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
