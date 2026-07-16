import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../providers/parent_data_providers.dart';
import '../widgets/parent_notification_tile.dart';
import '../widgets/parent_ui_constants.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(parentDashboardProvider);

    return dashboardState.when(
      loading: () => const _ParentLoadingView(),
      error: (error, stackTrace) {
        return _ParentErrorView(
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
              padding: EdgeInsets.only(bottom: ParentUiSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OrangeHeader(
                        parentName: dashboard.parentName,
                        trip: trip,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          ParentUiSpacing.lg,
                          horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionHeader(title: 'Recent Notifications'),
                            const SizedBox(height: ParentUiSpacing.md),
                            ...dashboard.recentNotifications.map((
                              notification,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: ParentUiSpacing.sm,
                                ),
                                child: ParentNotificationTile(
                                  title: notification.title,
                                  message: notification.time,
                                  time: '',
                                  type: _notificationTypeFromEntity(
                                    notification.type,
                                  ),
                                  isRead: notification.isRead,
                                ),
                              );
                            }),
                            const SizedBox(height: ParentUiSpacing.lg),
                            _StudentInfoCard(
                              childName: dashboard.childName,
                              grade: dashboard.grade,
                              busNumber: trip.busNumber,
                            ),
                            const SizedBox(height: ParentUiSpacing.xl),
                            const _PrimaryActionButton(
                              icon: Icons.near_me_outlined,
                              label: 'View Live Map',
                            ),
                            const SizedBox(height: ParentUiSpacing.md),
                            const _OutlineActionButton(
                              icon: Icons.call_outlined,
                              label: 'Contact Driver',
                            ),
                          ],
                        ),
                      ),
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

class _OrangeHeader extends StatelessWidget {
  const _OrangeHeader({required this.parentName, required this.trip});

  final String parentName;
  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        ParentUiSpacing.lg,
        ParentUiSpacing.xl,
        ParentUiSpacing.lg,
        ParentUiSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: ParentUiColors.orange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Track your child's bus in real-time",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: ParentUiSpacing.xl),
          _BusOverviewCard(trip: trip),
        ],
      ),
    );
  }
}

class _BusOverviewCard extends StatelessWidget {
  const _BusOverviewCard({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ParentUiColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: ParentUiColors.lightOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: ParentUiColors.orange,
                  size: 30,
                ),
              ),
              const SizedBox(width: ParentUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.busNumber, style: ParentUiTextStyles.heading),
                    const SizedBox(height: 4),
                    Text(trip.childName, style: ParentUiTextStyles.caption),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: ParentUiColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trip.statusLabel,
                    style: ParentUiTextStyles.body.copyWith(
                      color: ParentUiColors.success,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: ParentUiSpacing.md),
          const Divider(color: ParentUiColors.border),
          const SizedBox(height: ParentUiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _BusInfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Current Stop',
                  value: trip.currentStop,
                ),
              ),
              Expanded(
                child: _BusInfoItem(
                  icon: Icons.access_time_rounded,
                  label: 'ETA',
                  value: trip.eta,
                ),
              ),
            ],
          ),
          const SizedBox(height: ParentUiSpacing.md),
          const Divider(color: ParentUiColors.border),
          const SizedBox(height: ParentUiSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Next: ${trip.nextStop}',
                  style: ParentUiTextStyles.body.copyWith(
                    color: ParentUiColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ParentUiSpacing.md,
                  vertical: ParentUiSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: ParentUiColors.lightOrange,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${trip.stopsAway} stops away',
                  style: ParentUiTextStyles.caption.copyWith(
                    color: ParentUiColors.darkOrange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusInfoItem extends StatelessWidget {
  const _BusInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ParentUiColors.orange, size: 24),
        const SizedBox(width: ParentUiSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ParentUiTextStyles.caption),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ParentUiTextStyles.body.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentInfoCard extends StatelessWidget {
  const _StudentInfoCard({
    required this.childName,
    required this.grade,
    required this.busNumber,
  });

  final String childName;
  final String grade;
  final String busNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ParentUiColors.lightOrange,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ParentUiColors.orange),
      ),
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Information', style: ParentUiTextStyles.heading),
          const SizedBox(height: ParentUiSpacing.md),
          Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: ParentUiColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: ParentUiColors.orange),
                ),
                child: const Icon(
                  Icons.child_care_rounded,
                  color: Colors.white,
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
                      '$grade • $busNumber',
                      style: ParentUiTextStyles.body.copyWith(
                        color: ParentUiColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: ParentUiColors.orange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: ParentUiColors.orange),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: ParentUiColors.orange,
          side: const BorderSide(color: ParentUiColors.orange, width: 2),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: ParentUiTextStyles.heading.copyWith(fontSize: 22),
          ),
        ),
        const Icon(
          Icons.notifications_none_rounded,
          color: ParentUiColors.orange,
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
  const _ParentErrorView({required this.onRetry});

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
                'Failed to load parent dashboard.',
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
