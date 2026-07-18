import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final filtered = _unreadOnly
        ? notifications.where((n) => !n.isRead).toList()
        : notifications;

    // NotificationsScreen doubles as the Alerts bottom-nav tab (where it's
    // the root of the IndexedStack and shouldn't show a back button) and as
    // a screen pushed from elsewhere, e.g. Profile's Notifications settings
    // tile (where it needs one). Navigator.canPop tells us which case we're
    // in without needing a separate parameter.
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: Stack(
                  children: [
                    HeaderTitleBlock(
                      title: 'Notifications',
                      subtitle: 'Stay updated with alerts',
                      onBack: canPop ? () => Navigator.of(context).pop() : null,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AdminUiRadii.chip,
                          ),
                        ),
                        child: Text(
                          '$unreadCount new',
                          style: const TextStyle(
                            color: AdminUiColors.primaryOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterTab(
                        label: 'All (${notifications.length})',
                        selected: !_unreadOnly,
                        onTap: () => setState(() => _unreadOnly = false),
                      ),
                    ),
                    const SizedBox(width: AdminUiSpacing.sm),
                    Expanded(
                      child: _FilterTab(
                        label: 'Unread ($unreadCount)',
                        selected: _unreadOnly,
                        onTap: () => setState(() => _unreadOnly = true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                0,
                AdminUiSpacing.md,
                AdminUiSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => ref
                        .read(notificationsProvider.notifier)
                        .markAllAsRead(),
                    child: const Text('Mark All as Read'),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminUiSpacing.md,
              ),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AdminUiSpacing.sm),
                itemBuilder: (context, index) => _NotificationCard(
                  notification: filtered[index],
                  onMarkRead: () => ref
                      .read(notificationsProvider.notifier)
                      .markAsRead(filtered[index].notificationId),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AdminUiSpacing.lg),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminUiRadii.button),
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AdminUiColors.primaryOrange
              : AdminUiColors.cardBackground,
          borderRadius: BorderRadius.circular(AdminUiRadii.button),
          border: Border.all(
            color: selected
                ? AdminUiColors.primaryOrange
                : AdminUiColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AdminUiColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkRead;

  const _NotificationCard({
    required this.notification,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final visual = resolveNotificationVisual(notification);

    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(
          color: notification.isRead
              ? AdminUiColors.divider
              : AdminUiColors.primaryOrangeLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: visual.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(visual.icon, size: 17, color: visual.foreground),
              ),
              if (!notification.isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AdminUiColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AdminUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visual.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: AdminUiColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      relativeTime(notification.timestamp),
                      style: const TextStyle(
                        color: AdminUiColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const Spacer(),
                      InkWell(
                        onTap: onMarkRead,
                        mouseCursor: SystemMouseCursors.click,
                        child: const Text(
                          'Mark read',
                          style: TextStyle(
                            color: AdminUiColors.infoFg,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
