import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_notification_entity.dart';
import '../providers/parent_data_providers.dart';
import '../providers/parent_notification_actions_provider.dart';
import '../providers/parent_notification_center_provider.dart';
import '../widgets/parent_ui_constants.dart';

class ParentNotificationsScreen extends ConsumerWidget {
  const ParentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(parentNotificationsStreamProvider);
    final selectedFilter = ref.watch(parentNotificationFilterProvider);

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: notificationsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _NotificationErrorState(message: error.toString()),
          data: (notifications) {
            final visibleNotifications = _filterNotifications(
              notifications,
              selectedFilter,
            );

            return _NotificationsContent(
              notifications: notifications,
              visibleNotifications: visibleNotifications,
              selectedFilter: selectedFilter,
            );
          },
        ),
      ),
    );
  }

  List<ParentNotificationEntity> _filterNotifications(
    List<ParentNotificationEntity> notifications,
    ParentNotificationFilter filter,
  ) {
    switch (filter) {
      case ParentNotificationFilter.all:
        return notifications;
      case ParentNotificationFilter.unread:
        return notifications
            .where((notification) => !notification.isRead)
            .toList();
    }
  }
}

class _NotificationsContent extends ConsumerWidget {
  const _NotificationsContent({
    required this.notifications,
    required this.visibleNotifications,
    required this.selectedFilter,
  });

  final List<ParentNotificationEntity> notifications;
  final List<ParentNotificationEntity> visibleNotifications;
  final ParentNotificationFilter selectedFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = notifications.where((item) => !item.isRead).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          _NotificationsHeader(unreadCount: unreadCount),
          const SizedBox(height: 18),
          _NotificationFilters(selectedFilter: selectedFilter),
          const SizedBox(height: 12),
          _MarkAllReadButton(
            unreadCount: unreadCount,
            onPressed: unreadCount == 0
                ? null
                : () async {
                    await ref
                        .read(parentNotificationActionsProvider)
                        .markAllAsRead();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read.'),
                      ),
                    );
                  },
          ),
          const SizedBox(height: 12),
          if (visibleNotifications.isEmpty)
            const _EmptyNotificationsCard()
          else
            for (final notification in visibleNotifications)
              _NotificationCard(notification: notification),
        ],
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: ParentUiColors.orange,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Stay updated with bus alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$unreadCount new',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationFilters extends ConsumerWidget {
  const _NotificationFilters({required this.selectedFilter});

  final ParentNotificationFilter selectedFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChipButton(
            label: 'All',
            isSelected: selectedFilter == ParentNotificationFilter.all,
            onTap: () {
              ref
                  .read(parentNotificationFilterProvider.notifier)
                  .selectFilter(ParentNotificationFilter.all);
            },
          ),
          const SizedBox(width: 10),
          _FilterChipButton(
            label: 'Unread',
            isSelected: selectedFilter == ParentNotificationFilter.unread,
            onTap: () {
              ref
                  .read(parentNotificationFilterProvider.notifier)
                  .selectFilter(ParentNotificationFilter.unread);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: ParentUiColors.orange.withValues(alpha: 0.16),
      labelStyle: TextStyle(
        color: isSelected ? ParentUiColors.orange : Colors.grey.shade700,
        fontWeight: FontWeight.w800,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({
    required this.unreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.done_all),
        label: Text(
          unreadCount == 0 ? 'All notifications read' : 'Mark All as Read',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: ParentUiColors.orange,
          side: const BorderSide(color: ParentUiColors.orange),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({required this.notification});

  final ParentNotificationEntity notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = _notificationStyle(notification.type);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: notification.isRead
              ? Colors.transparent
              : ParentUiColors.orange.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            _showNotificationDetailsDialog(context, ref, notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(style.icon, color: style.foreground),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              height: 9,
                              width: 9,
                              decoration: const BoxDecoration(
                                color: ParentUiColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            notification.time,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (!notification.isRead)
                            TextButton(
                              onPressed: () async {
                                await ref
                                    .read(parentNotificationActionsProvider)
                                    .markAsRead(notification.id);

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notification marked as read.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Mark read'),
                            ),
                        ],
                      ),
                    ],
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

class _EmptyNotificationsCard extends StatelessWidget {
  const _EmptyNotificationsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none,
            color: ParentUiColors.orange,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'No notifications to show.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _NotificationErrorState extends StatelessWidget {
  const _NotificationErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Unable to load notifications.\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _NotificationStyle {
  const _NotificationStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

_NotificationStyle _notificationStyle(ParentAlertType type) {
  switch (type) {
    case ParentAlertType.boarded:
      return _NotificationStyle(
        icon: Icons.directions_bus_filled,
        background: Colors.green.withValues(alpha: 0.12),
        foreground: Colors.green,
      );
    case ParentAlertType.dropped:
      return _NotificationStyle(
        icon: Icons.check_circle,
        background: Colors.blue.withValues(alpha: 0.12),
        foreground: Colors.blue,
      );
    case ParentAlertType.delay:
      return _NotificationStyle(
        icon: Icons.warning_amber,
        background: Colors.orange.withValues(alpha: 0.14),
        foreground: Colors.orange,
      );
    case ParentAlertType.emergency:
      return _NotificationStyle(
        icon: Icons.emergency,
        background: Colors.red.withValues(alpha: 0.12),
        foreground: Colors.red,
      );
    case ParentAlertType.general:
      return _NotificationStyle(
        icon: Icons.notifications,
        background: ParentUiColors.orange.withValues(alpha: 0.12),
        foreground: ParentUiColors.orange,
      );
  }
}

void _showNotificationDetailsDialog(
  BuildContext context,
  WidgetRef ref,
  ParentNotificationEntity notification,
) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          if (!notification.isRead)
            TextButton(
              onPressed: () async {
                await ref
                    .read(parentNotificationActionsProvider)
                    .markAsRead(notification.id);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);
              },
              child: const Text('Mark read'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
