import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import 'admin_ui_constants.dart';

class NotificationVisual {
  final IconData icon;
  final Color background;
  final Color foreground;
  final String title;

  const NotificationVisual({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.title,
  });
}

NotificationVisual resolveNotificationVisual(NotificationModel notification) {
  final message = notification.message.toLowerCase();

  if (message.contains('delayed')) {
    return const NotificationVisual(
      icon: Icons.access_time_filled_rounded,
      background: AdminUiColors.delayedBg,
      foreground: AdminUiColors.delayedFg,
      title: 'Bus delayed',
    );
  }
  if (message.contains('completed')) {
    return const NotificationVisual(
      icon: Icons.check_circle_rounded,
      background: AdminUiColors.onTimeBg,
      foreground: AdminUiColors.onTimeFg,
      title: 'Routes completed',
    );
  }
  if (message.contains('rain') || message.contains('weather')) {
    return const NotificationVisual(
      icon: Icons.wb_cloudy_rounded,
      background: AdminUiColors.statCardBackground,
      foreground: AdminUiColors.primaryOrange,
      title: 'Weather alert',
    );
  }
  if (message.contains('assigned') || message.contains('started route')) {
    return const NotificationVisual(
      icon: Icons.info_rounded,
      background: AdminUiColors.infoBg,
      foreground: AdminUiColors.infoFg,
      title: 'Driver check-in',
    );
  }
  return const NotificationVisual(
    icon: Icons.info_rounded,
    background: AdminUiColors.infoBg,
    foreground: AdminUiColors.infoFg,
    title: 'Notification',
  );
}

String relativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  return 'Yesterday';
}

class AlertPreviewTile extends StatelessWidget {
  final NotificationModel notification;

  const AlertPreviewTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final visual = resolveNotificationVisual(notification);

    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Row(
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
          const SizedBox(width: AdminUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  relativeTime(notification.timestamp),
                  style: const TextStyle(
                    color: AdminUiColors.textSecondary,
                    fontSize: 12,
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
