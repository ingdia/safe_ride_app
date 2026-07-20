import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_trip_entity.dart';
import '../providers/parent_data_providers.dart';
import '../widgets/parent_ui_constants.dart';

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                const _MapHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _MapPreview(trip: trip),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ParentUiSpacing.lg,
                            ParentUiSpacing.lg,
                            ParentUiSpacing.lg,
                            ParentUiSpacing.xl,
                          ),
                          child: Column(
                            children: [
                              _RouteStopsHeader(
                                stopCount: trip.routeStops.length,
                              ),
                              const SizedBox(height: ParentUiSpacing.md),
                              ...trip.routeStops.map((stop) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: ParentUiSpacing.md,
                                  ),
                                  child: _RouteStopCard(stop: stop),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        ParentUiSpacing.lg,
        ParentUiSpacing.xl,
        ParentUiSpacing.lg,
        ParentUiSpacing.lg,
      ),
      color: ParentUiColors.orange,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Map',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Real-time bus tracking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFFF4C7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFFFD65A), width: 4)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 120,
            top: 120,
            child: _SmallMapDot(color: ParentUiColors.success),
          ),
          const Positioned(
            left: 230,
            top: 176,
            child: _SmallMapDot(color: ParentUiColors.orange),
          ),
          const Positioned(
            right: 210,
            top: 215,
            child: _SmallMapDot(color: ParentUiColors.success),
          ),
          const Positioned(
            right: 170,
            top: 252,
            child: _SmallMapDot(color: ParentUiColors.textSecondary),
          ),
          Container(
            width: 258,
            padding: const EdgeInsets.symmetric(
              horizontal: ParentUiSpacing.lg,
              vertical: ParentUiSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.navigation_outlined,
                      color: ParentUiColors.orange,
                      size: 86,
                    ),
                    Container(
                      height: 62,
                      width: 62,
                      decoration: const BoxDecoration(
                        color: ParentUiColors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ParentUiSpacing.md),
                Text(
                  'Interactive Map View',
                  textAlign: TextAlign.center,
                  style: ParentUiTextStyles.heading.copyWith(fontSize: 20),
                ),
                const SizedBox(height: ParentUiSpacing.xs),
                Text(
                  'GPS tracking visualization',
                  textAlign: TextAlign.center,
                  style: ParentUiTextStyles.body.copyWith(
                    color: ParentUiColors.textSecondary,
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

class _SmallMapDot extends StatelessWidget {
  const _SmallMapDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      width: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _RouteStopsHeader extends StatelessWidget {
  const _RouteStopsHeader({required this.stopCount});

  final int stopCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Route Stops',
            style: ParentUiTextStyles.heading.copyWith(fontSize: 24),
          ),
        ),
        Text(
          '$stopCount stops',
          style: ParentUiTextStyles.body.copyWith(
            color: ParentUiColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RouteStopCard extends StatelessWidget {
  const _RouteStopCard({required this.stop});

  final ParentRouteStopEntity stop;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(stop.status);

    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusStyle.borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusStyle.circleColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              stop.position.toString(),
              style: TextStyle(
                color: statusStyle.numberColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: ParentUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ParentUiTextStyles.heading.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: ParentUiColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        stop.time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ParentUiTextStyles.body.copyWith(
                          color: ParentUiColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: ParentUiSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ParentUiSpacing.md,
              vertical: ParentUiSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: statusStyle.badgeBackground,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              statusStyle.label,
              style: ParentUiTextStyles.caption.copyWith(
                color: statusStyle.badgeText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _RouteStopStatusStyle _statusStyle(ParentRouteStopStatus status) {
    switch (status) {
      case ParentRouteStopStatus.completed:
        return const _RouteStopStatusStyle(
          label: 'Completed',
          borderColor: Color(0xFF86EFAC),
          circleColor: Color(0xFFDCFCE7),
          numberColor: Color(0xFF15803D),
          badgeBackground: Color(0xFFDCFCE7),
          badgeText: Color(0xFF16A34A),
        );
      case ParentRouteStopStatus.current:
        return const _RouteStopStatusStyle(
          label: 'Current',
          borderColor: ParentUiColors.orange,
          circleColor: ParentUiColors.lightOrange,
          numberColor: ParentUiColors.darkOrange,
          badgeBackground: ParentUiColors.lightOrange,
          badgeText: ParentUiColors.darkOrange,
        );
      case ParentRouteStopStatus.upcoming:
        return const _RouteStopStatusStyle(
          label: 'Upcoming',
          borderColor: ParentUiColors.border,
          circleColor: Color(0xFFF3F4F6),
          numberColor: ParentUiColors.textSecondary,
          badgeBackground: Color(0xFFF3F4F6),
          badgeText: ParentUiColors.textSecondary,
        );
    }
  }
}

class _RouteStopStatusStyle {
  const _RouteStopStatusStyle({
    required this.label,
    required this.borderColor,
    required this.circleColor,
    required this.numberColor,
    required this.badgeBackground,
    required this.badgeText,
  });

  final String label;
  final Color borderColor;
  final Color circleColor;
  final Color numberColor;
  final Color badgeBackground;
  final Color badgeText;
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
                'Failed to load live map.',
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
