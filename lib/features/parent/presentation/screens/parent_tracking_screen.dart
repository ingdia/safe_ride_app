import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_trip_entity.dart';
import '../providers/parent_data_providers.dart';
import '../widgets/parent_ui_constants.dart';
import '../widgets/route_stop_tile.dart';

class ParentTrackingScreen extends ConsumerWidget {
  const ParentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(parentLiveTripProvider);

    return tripState.when(
      loading: () => const _TrackingLoadingView(),
      error: (error, stackTrace) {
        return _TrackingErrorView(
          onRetry: () {
            ref.invalidate(parentLiveTripProvider);
          },
        );
      },
      data: (trip) {
        return _TrackingContent(trip: trip);
      },
    );
  }
}

class _TrackingContent extends StatelessWidget {
  const _TrackingContent({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 600
                ? ParentUiSpacing.xl
                : ParentUiSpacing.md;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                ParentUiSpacing.md,
                horizontalPadding,
                ParentUiSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TrackingHeader(),
                      const SizedBox(height: ParentUiSpacing.lg),
                      _LiveMapCard(trip: trip),
                      const SizedBox(height: ParentUiSpacing.lg),
                      _TripInfoCard(trip: trip),
                      const SizedBox(height: ParentUiSpacing.lg),
                      Text('Route progress', style: ParentUiTextStyles.heading),
                      const SizedBox(height: ParentUiSpacing.sm),
                      ...trip.routeStops.map((stop) {
                        return RouteStopTile(
                          stopName: stop.name,
                          time: stop.time,
                          status: _routeStopStatusFromEntity(stop.status),
                          position: stop.position,
                          isLast: stop.position == trip.routeStops.length,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  RouteStopStatus _routeStopStatusFromEntity(ParentRouteStopStatus status) {
    switch (status) {
      case ParentRouteStopStatus.completed:
        return RouteStopStatus.completed;
      case ParentRouteStopStatus.current:
        return RouteStopStatus.current;
      case ParentRouteStopStatus.upcoming:
        return RouteStopStatus.upcoming;
    }
  }
}

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: ParentUiColors.lightOrange,
            borderRadius: BorderRadius.circular(ParentUiRadius.md),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: ParentUiColors.orange,
          ),
        ),
        const SizedBox(width: ParentUiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live tracking',
                style: ParentUiTextStyles.title.copyWith(height: 1.1),
              ),
              const SizedBox(height: 4),
              Text(
                'Follow the school bus in real time',
                style: ParentUiTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveMapCard extends StatelessWidget {
  const _LiveMapCard({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7C2),
        borderRadius: BorderRadius.circular(ParentUiRadius.xl),
        border: Border.all(color: ParentUiColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 52,
            right: 24,
            child: _MapRoadLine(width: double.infinity),
          ),
          Positioned(
            left: 62,
            top: 132,
            right: 48,
            child: _MapRoadLine(width: double.infinity),
          ),
          Positioned(
            left: 28,
            bottom: 62,
            right: 92,
            child: _MapRoadLine(width: double.infinity),
          ),
          const Positioned(
            left: 34,
            top: 94,
            child: _MapMarker(
              icon: Icons.home_rounded,
              color: ParentUiColors.blue,
            ),
          ),
          const Positioned(
            right: 54,
            top: 82,
            child: _MapMarker(
              icon: Icons.directions_bus_rounded,
              color: ParentUiColors.orange,
              size: 62,
            ),
          ),
          const Positioned(
            left: 96,
            bottom: 42,
            child: _MapMarker(
              icon: Icons.school_rounded,
              color: ParentUiColors.success,
            ),
          ),
          Positioned(
            left: ParentUiSpacing.md,
            right: ParentUiSpacing.md,
            bottom: ParentUiSpacing.md,
            child: Container(
              padding: const EdgeInsets.all(ParentUiSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ParentUiRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_bus_filled_rounded,
                    color: ParentUiColors.orange,
                  ),
                  const SizedBox(width: ParentUiSpacing.sm),
                  Expanded(
                    child: Text(
                      '${trip.busNumber} is near ${trip.currentStop}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ParentUiTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: ParentUiSpacing.sm),
                  Text(
                    trip.eta,
                    style: ParentUiTextStyles.body.copyWith(
                      color: ParentUiColors.darkOrange,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripInfoCard extends StatelessWidget {
  const _TripInfoCard({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: parentCardDecoration(),
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current trip', style: ParentUiTextStyles.heading),
          const SizedBox(height: ParentUiSpacing.md),
          _TripInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Child',
            value: trip.childName,
          ),
          _TripInfoRow(
            icon: Icons.directions_bus_outlined,
            label: 'Bus',
            value: trip.busNumber,
          ),
          _TripInfoRow(
            icon: Icons.person_pin_outlined,
            label: 'Driver',
            value: trip.driverName,
          ),
          _TripInfoRow(
            icon: Icons.near_me_outlined,
            label: 'Next stop',
            value: trip.nextStop,
          ),
          _TripInfoRow(
            icon: Icons.timer_outlined,
            label: 'ETA',
            value: '${trip.eta} • ${trip.stopsAway} stops away',
          ),
        ],
      ),
    );
  }
}

class _TripInfoRow extends StatelessWidget {
  const _TripInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ParentUiSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: ParentUiColors.orange, size: 22),
          const SizedBox(width: ParentUiSpacing.sm),
          Expanded(child: Text(label, style: ParentUiTextStyles.caption)),
          const SizedBox(width: ParentUiSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: ParentUiTextStyles.body.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapRoadLine extends StatelessWidget {
  const _MapRoadLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.icon, required this.color, this.size = 48});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.88, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.48),
      ),
    );
  }
}

class _TrackingLoadingView extends StatelessWidget {
  const _TrackingLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ParentUiColors.background,
      body: Center(
        child: CircularProgressIndicator(color: ParentUiColors.orange),
      ),
    );
  }
}

class _TrackingErrorView extends StatelessWidget {
  const _TrackingErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ParentUiSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: ParentUiColors.danger,
                size: 42,
              ),
              const SizedBox(height: ParentUiSpacing.md),
              Text(
                'Failed to load live tracking.',
                textAlign: TextAlign.center,
                style: ParentUiTextStyles.body,
              ),
              const SizedBox(height: ParentUiSpacing.md),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
