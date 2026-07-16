import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_notification_entity.dart';
import '../providers/parent_data_providers.dart';
import '../widgets/parent_ui_constants.dart';

class ParentNotificationsScreen extends ConsumerWidget {
  const ParentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(parentNotificationsProvider);

    return notificationsState.when(
      loading: () => const _NotificationsLoadingView(),
      error: (error, stackTrace) {
        return _NotificationsErrorView(
          onRetry: () {
            ref.invalidate(parentNotificationsProvider);
          },
        );
      },
      data: (notifications) {
        return _NotificationsContent(notifications: notifications);
      },
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent({required this.notifications});

  final List<ParentNotificationEntity> notifications;

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications
        .where((notification) => !notification.isRead)
        .length;

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _NotificationsHeader(
                  totalCount: notifications.length,
                  unreadCount: unreadCount,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      ParentUiSpacing.lg,
                      ParentUiSpacing.lg,
                      ParentUiSpacing.lg,
                      ParentUiSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        const _MarkAllAsReadButton(),
                        const SizedBox(height: ParentUiSpacing.lg),
                        ...notifications.map((notification) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: ParentUiSpacing.md,
                            ),
                            child: _NotificationCard(
                              notification: notification,
                            ),
                          );
                        }),
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

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.totalCount,
    required this.unreadCount,
  });

  final int totalCount;
  final int unreadCount;

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
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stay updated with alerts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ParentUiSpacing.lg,
                  vertical: ParentUiSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ParentUiSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _FilterChipButton(
                  label: 'All ($totalCount)',
                  isSelected: true,
                ),
              ),
              const SizedBox(width: ParentUiSpacing.sm),
              Expanded(
                child: _FilterChipButton(
                  label: 'Unread ($unreadCount)',
                  isSelected: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? ParentUiColors.darkOrange : Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MarkAllAsReadButton extends StatelessWidget {
  const _MarkAllAsReadButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: ParentUiColors.orange, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          foregroundColor: ParentUiColors.darkOrange,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        child: const Text('Mark All as Read'),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final ParentNotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    final style = _notificationStyle(notification.type);
    final isUnread = !notification.isRead;

    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isUnread ? ParentUiColors.orange : ParentUiColors.border,
          width: isUnread ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(style.icon, color: style.iconColor, size: 28),
              ),
              const SizedBox(width: ParentUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: ParentUiTextStyles.heading.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: ParentUiSpacing.xs),
                    Text(
                      notification.message,
                      style: ParentUiTextStyles.body.copyWith(
                        color: const Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: ParentUiSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: ParentUiColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notification.time,
                          style: ParentUiTextStyles.caption.copyWith(
                            color: ParentUiColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (isUnread)
                          Text(
                            'Mark read',
                            style: ParentUiTextStyles.caption.copyWith(
                              color: ParentUiColors.darkOrange,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isUnread)
            const Positioned(
              right: 2,
              top: 2,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: ParentUiColors.orange,
              ),
            ),
        ],
      ),
    );
  }

  _NotificationStyle _notificationStyle(ParentAlertType type) {
    switch (type) {
      case ParentAlertType.boarded:
      case ParentAlertType.dropped:
        return const _NotificationStyle(
          icon: Icons.check_circle_outline_rounded,
          iconColor: Color(0xFF16A34A),
          backgroundColor: Color(0xFFDCFCE7),
        );
      case ParentAlertType.delay:
      case ParentAlertType.emergency:
        return const _NotificationStyle(
          icon: Icons.error_outline_rounded,
          iconColor: ParentUiColors.orange,
          backgroundColor: ParentUiColors.lightOrange,
        );
      case ParentAlertType.general:
        return const _NotificationStyle(
          icon: Icons.info_outline_rounded,
          iconColor: Color(0xFF2563EB),
          backgroundColor: Color(0xFFDBEAFE),
        );
    }
  }
}

class _NotificationStyle {
  const _NotificationStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}

class _NotificationsLoadingView extends StatelessWidget {
  const _NotificationsLoadingView();

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

class _NotificationsErrorView extends StatelessWidget {
  const _NotificationsErrorView({required this.onRetry});

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
                'Failed to load notifications.',
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
