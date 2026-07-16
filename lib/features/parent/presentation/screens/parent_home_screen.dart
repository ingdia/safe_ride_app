import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../providers/parent_data_providers.dart';
import '../widgets/parent_bus_status_card.dart';
import '../widgets/parent_notification_tile.dart';
import '../widgets/parent_ui_constants.dart';
import '../widgets/route_stop_tile.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(parentDashboardProvider);

    return dashboardState.when(
      loading: () => const _ParentLoadingView(),
      error: (error, stackTrace) {
        return _ParentErrorView(
          message: 'Failed to load parent dashboard.',
          onRetry: () {
            ref.invalidate(parentDashboardProvider);
          },
        );
      },
      data: (dashboard) {
        return _ParentHomeContent(dashboard: dashboard);
      },
    );
  }
}

class _ParentHomeContent extends StatelessWidget {
  const _ParentHomeContent({required this.dashboard});

  final ParentDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final trip = dashboard.trip;

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
                      _ParentHeader(parentName: dashboard.parentName),
                      const SizedBox(height: ParentUiSpacing.lg),
                      ParentBusStatusCard(
                        childName: trip.childName,
                        busNumber: trip.busNumber,
                        status: trip.statusLabel,
                        currentStop: trip.currentStop,
                        nextStop: trip.nextStop,
                        eta: trip.eta,
                        stopsAway: trip.stopsAway,
                        progress: trip.progress,
                        isOnTime: trip.isOnTime,
                      ),
                      const SizedBox(height: ParentUiSpacing.lg),
                      _ChildSummaryCard(
                        childName: dashboard.childName,
                        schoolName: dashboard.schoolName,
                        grade: dashboard.grade,
                        statusLabel: trip.statusLabel,
                        isSafe: trip.status != ParentTripStatus.emergency,
                      ),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _SectionHeader(
                        title: 'Quick actions',
                        actionText: '',
                      ),
                      const SizedBox(height: ParentUiSpacing.sm),
                      const _QuickActionsGrid(),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _SectionHeader(
                        title: 'Live tracking preview',
                        actionText: 'View map',
                      ),
                      const SizedBox(height: ParentUiSpacing.sm),
                      _MapPreviewCard(eta: trip.eta),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _SectionHeader(
                        title: 'Today route',
                        actionText: '',
                      ),
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
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _SectionHeader(
                        title: 'Recent notifications',
                        actionText: 'See all',
                      ),
                      const SizedBox(height: ParentUiSpacing.sm),
                      ...dashboard.recentNotifications.map((notification) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: ParentUiSpacing.sm,
                          ),
                          child: ParentNotificationTile(
                            title: notification.title,
                            message: notification.message,
                            time: notification.time,
                            type: _notificationTypeFromEntity(
                              notification.type,
                            ),
                            isRead: notification.isRead,
                          ),
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

  ParentNotificationType _notificationTypeFromEntity(ParentAlertType type) {
    switch (type) {
      case ParentAlertType.boarded:
        return ParentNotificationType.boarded;
      case ParentAlertType.dropped:
        return ParentNotificationType.dropped;
      case ParentAlertType.delay:
        return ParentNotificationType.delay;
      case ParentAlertType.emergency:
        return ParentNotificationType.emergency;
      case ParentAlertType.general:
        return ParentNotificationType.general;
    }
  }
}

class _ParentHeader extends StatelessWidget {
  const _ParentHeader({required this.parentName});

  final String parentName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, $parentName',
                style: ParentUiTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your child safely',
                style: ParentUiTextStyles.title.copyWith(height: 1.1),
              ),
            ],
          ),
        ),
        const SizedBox(width: ParentUiSpacing.md),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: ParentUiColors.lightOrange,
            borderRadius: BorderRadius.circular(ParentUiRadius.md),
            border: Border.all(color: ParentUiColors.border),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: ParentUiColors.orange,
          ),
        ),
      ],
    );
  }
}

class _ChildSummaryCard extends StatelessWidget {
  const _ChildSummaryCard({
    required this.childName,
    required this.schoolName,
    required this.grade,
    required this.statusLabel,
    required this.isSafe,
  });

  final String childName;
  final String schoolName;
  final String grade;
  final String statusLabel;
  final bool isSafe;

  @override
  Widget build(BuildContext context) {
    final badgeColor = isSafe ? ParentUiColors.success : ParentUiColors.danger;

    return Container(
      decoration: parentCardDecoration(),
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: ParentUiColors.lightOrange,
              borderRadius: BorderRadius.circular(ParentUiRadius.lg),
            ),
            child: const Icon(
              Icons.child_care_rounded,
              color: ParentUiColors.orange,
              size: 30,
            ),
          ),
          const SizedBox(width: ParentUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(childName, style: ParentUiTextStyles.heading),
                const SizedBox(height: 4),
                Text(
                  '$grade • $schoolName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ParentUiTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: ParentUiSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ParentUiSpacing.sm,
              vertical: ParentUiSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              statusLabel,
              style: ParentUiTextStyles.caption.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 520;

        final actions = [
          const _QuickActionCard(
            icon: Icons.map_outlined,
            title: 'Live map',
            subtitle: 'View bus location',
          ),
          const _QuickActionCard(
            icon: Icons.notifications_none_rounded,
            title: 'Alerts',
            subtitle: 'Boarding and drop-off',
          ),
          const _QuickActionCard(
            icon: Icons.call_outlined,
            title: 'Contact school',
            subtitle: 'Ask for support',
          ),
          const _QuickActionCard(
            icon: Icons.history_rounded,
            title: 'Trip history',
            subtitle: 'View previous trips',
          ),
        ];

        if (!useTwoColumns) {
          return Column(
            children: actions
                .map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: ParentUiSpacing.sm),
                    child: action,
                  ),
                )
                .toList(),
          );
        }

        return Wrap(
          spacing: ParentUiSpacing.sm,
          runSpacing: ParentUiSpacing.sm,
          children: actions
              .map(
                (action) => SizedBox(
                  width: (constraints.maxWidth - ParentUiSpacing.sm) / 2,
                  child: action,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: parentCardDecoration(),
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: ParentUiColors.lightOrange,
              borderRadius: BorderRadius.circular(ParentUiRadius.sm),
            ),
            child: Icon(icon, color: ParentUiColors.orange),
          ),
          const SizedBox(width: ParentUiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ParentUiTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ParentUiTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.eta});

  final String eta;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7C2),
        borderRadius: BorderRadius.circular(ParentUiRadius.lg),
        border: Border.all(color: ParentUiColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 26,
            right: 24,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            left: 58,
            top: 74,
            right: 42,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 36,
            right: 80,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const Positioned(
            left: 40,
            top: 52,
            child: _MapPoint(
              icon: Icons.home_rounded,
              color: ParentUiColors.blue,
            ),
          ),
          const Positioned(
            right: 54,
            top: 48,
            child: _MapPoint(
              icon: Icons.directions_bus_rounded,
              color: ParentUiColors.orange,
              size: 52,
            ),
          ),
          const Positioned(
            left: 92,
            bottom: 26,
            child: _MapPoint(
              icon: Icons.school_rounded,
              color: ParentUiColors.success,
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ParentUiSpacing.sm,
                vertical: ParentUiSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'ETA $eta',
                style: ParentUiTextStyles.caption.copyWith(
                  color: ParentUiColors.darkOrange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPoint extends StatelessWidget {
  const _MapPoint({required this.icon, required this.color, this.size = 42});

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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionText});

  final String title;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: ParentUiTextStyles.heading)),
        if (actionText.isNotEmpty)
          Text(
            actionText,
            style: ParentUiTextStyles.caption.copyWith(
              color: ParentUiColors.orange,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }
}

class _ParentLoadingView extends StatelessWidget {
  const _ParentLoadingView();

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

class _ParentErrorView extends StatelessWidget {
  const _ParentErrorView({required this.message, required this.onRetry});

  final String message;
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
                message,
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
