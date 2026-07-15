import 'package:flutter/material.dart';

import '../widgets/parent_notification_tile.dart';
import '../widgets/parent_ui_constants.dart';

class ParentNotificationsScreen extends StatelessWidget {
  const ParentNotificationsScreen({super.key});

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
                      const _NotificationsHeader(),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _NotificationSummaryCard(),
                      const SizedBox(height: ParentUiSpacing.lg),
                      const _FilterChipsRow(),
                      const SizedBox(height: ParentUiSpacing.lg),
                      Text('Today', style: ParentUiTextStyles.heading),
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
                        title: 'Bus delay',
                        message:
                            'Bus KGL 204 is delayed by 5 minutes due to traffic near Kimironko.',
                        time: '7:22 AM',
                        type: ParentNotificationType.delay,
                      ),
                      const SizedBox(height: ParentUiSpacing.sm),
                      const ParentNotificationTile(
                        title: 'Bus is moving',
                        message:
                            'The bus is currently heading to the school gate.',
                        time: '7:30 AM',
                        type: ParentNotificationType.general,
                        isRead: true,
                      ),
                      const SizedBox(height: ParentUiSpacing.lg),
                      Text('Yesterday', style: ParentUiTextStyles.heading),
                      const SizedBox(height: ParentUiSpacing.sm),
                      const ParentNotificationTile(
                        title: 'Child dropped off',
                        message:
                            'Ineza was safely dropped off at Kacyiru pickup point.',
                        time: '4:18 PM',
                        type: ParentNotificationType.dropped,
                        isRead: true,
                      ),
                      const SizedBox(height: ParentUiSpacing.sm),
                      const ParentNotificationTile(
                        title: 'Trip completed',
                        message:
                            'The afternoon trip was completed successfully.',
                        time: '4:25 PM',
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

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: ParentUiColors.lightOrange,
            borderRadius: BorderRadius.circular(ParentUiRadius.md),
            border: Border.all(color: ParentUiColors.border),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: ParentUiColors.orange,
            size: 28,
          ),
        ),
        const SizedBox(width: ParentUiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications', style: ParentUiTextStyles.title),
              const SizedBox(height: 4),
              Text(
                'Boarding, drop-off, delay, and safety alerts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ParentUiTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationSummaryCard extends StatelessWidget {
  const _NotificationSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: parentCardDecoration(),
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 420;

          final items = [
            const _SummaryItem(
              icon: Icons.mark_email_unread_outlined,
              label: 'Unread',
              value: '2',
              color: ParentUiColors.orange,
            ),
            const _SummaryItem(
              icon: Icons.check_circle_outline_rounded,
              label: 'Safe updates',
              value: '4',
              color: ParentUiColors.success,
            ),
            const _SummaryItem(
              icon: Icons.warning_amber_rounded,
              label: 'Important',
              value: '1',
              color: ParentUiColors.warning,
            ),
          ];

          if (isSmall) {
            return Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: ParentUiSpacing.sm,
                      ),
                      child: item,
                    ),
                  )
                  .toList(),
            );
          }

          return Row(
            children: [
              Expanded(child: items[0]),
              const SizedBox(width: ParentUiSpacing.sm),
              Expanded(child: items[1]),
              const SizedBox(width: ParentUiSpacing.sm),
              Expanded(child: items[2]),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ParentUiRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: ParentUiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: ParentUiTextStyles.heading.copyWith(color: color),
                ),
                Text(
                  label,
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

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context) {
    final filters = [
      const _FilterChipItem(label: 'All', selected: true),
      const _FilterChipItem(label: 'Boarding', selected: false),
      const _FilterChipItem(label: 'Drop-off', selected: false),
      const _FilterChipItem(label: 'Delays', selected: false),
      const _FilterChipItem(label: 'SOS', selected: false),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: ParentUiSpacing.sm),
                child: filter,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ParentUiSpacing.md,
        vertical: ParentUiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected ? ParentUiColors.orange : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: selected ? ParentUiColors.orange : ParentUiColors.border,
        ),
      ),
      child: Text(
        label,
        style: ParentUiTextStyles.caption.copyWith(
          color: selected ? Colors.white : ParentUiColors.textGrey,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
