import 'package:flutter/material.dart';

import '../widgets/parent_bus_status_card.dart';
import '../widgets/parent_notification_tile.dart';
import '../widgets/parent_ui_constants.dart';
import '../widgets/route_stop_tile.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

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
                      const _ParentHeader(),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const ParentBusStatusCard(
                        childName: 'Ineza Juliette',
                        busNumber: 'Bus KGL 204',
                        status: 'On time',
                        currentStop: 'Kacyiru',
                        nextStop: 'Kimironko',
                        eta: '12 min',
                        stopsAway: 2,
                        progress: 0.64,
                      ),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _ChildSummaryCard(),
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
                      const _MapPreviewCard(),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _SectionHeader(
                        title: 'Today route',
                        actionText: '',
                      ),
                      const SizedBox(height: ParentUiSpacing.sm),
                      const RouteStopTile(
                        stopName: 'Kacyiru pickup point',
                        time: '07:10',
                        status: RouteStopStatus.completed,
                        position: 1,
                        isLast: false,
                      ),
                      const RouteStopTile(
                        stopName: 'Kimironko main road',
                        time: '07:25',
                        status: RouteStopStatus.current,
                        position: 2,
                        isLast: false,
                      ),
                      const RouteStopTile(
                        stopName: 'School gate',
                        time: '07:45',
                        status: RouteStopStatus.upcoming,
                        position: 3,
                        isLast: true,
                      ),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _SectionHeader(
                        title: 'Recent notifications',
                        actionText: 'See all',
                      ),
                      const SizedBox(height: ParentUiSpacing.sm),
                      const ParentNotificationTile(
                        title: 'Child boarded',
                        message:
                            'Ineza boarded Bus KGL 204 at Kacyiru pickup point.',
                        time: '7:10 AM',
                        type: ParentNotificationType.boarded,
                      ),
                      const SizedBox(height: ParentUiSpacing.sm),
                      const ParentNotificationTile(
                        title: 'Bus is moving',
                        message:
                            'The bus is currently heading to Kimironko main road.',
                        time: '7:18 AM',
                        type: ParentNotificationType.general,
                        isRead: true,
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
}

class _ParentHeader extends StatelessWidget {
  const _ParentHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Parent',
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
  const _ChildSummaryCard();

  @override
  Widget build(BuildContext context) {
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
                Text('Ineza Juliette', style: ParentUiTextStyles.heading),
                const SizedBox(height: 4),
                Text(
                  'Primary 4 • Kigali Parents School',
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
              color: const Color(0xFFE8F8EE),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'Safe',
              style: ParentUiTextStyles.caption.copyWith(
                color: ParentUiColors.success,
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
  const _MapPreviewCard();

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
                'ETA 12 min',
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
