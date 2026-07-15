import 'package:flutter/material.dart';

import 'parent_ui_constants.dart';

class ParentNotificationTile extends StatelessWidget {
  const ParentNotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.onTap,
  });

  final String title;
  final String message;
  final String time;
  final ParentNotificationType type;
  final bool isRead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final notificationStyle = _styleFromType(type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ParentUiRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ParentUiSpacing.md),
        decoration: parentCardDecoration(
          color: isRead ? Colors.white : ParentUiColors.lightOrange,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: notificationStyle.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                notificationStyle.icon,
                color: notificationStyle.iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: ParentUiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ParentUiTextStyles.body.copyWith(
                            fontWeight: isRead
                                ? FontWeight.w700
                                : FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: ParentUiSpacing.sm),
                      Text(time, style: ParentUiTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: ParentUiSpacing.xs),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ParentUiTextStyles.caption.copyWith(height: 1.35),
                  ),
                  if (!isRead) ...[
                    const SizedBox(height: ParentUiSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ParentUiSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ParentUiColors.orange,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'New alert',
                        style: ParentUiTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotificationTileStyle _styleFromType(ParentNotificationType type) {
    switch (type) {
      case ParentNotificationType.boarded:
        return const _NotificationTileStyle(
          icon: Icons.check_circle_outline_rounded,
          iconColor: ParentUiColors.success,
          backgroundColor: Color(0xFFE8F8EE),
        );
      case ParentNotificationType.dropped:
        return const _NotificationTileStyle(
          icon: Icons.home_outlined,
          iconColor: ParentUiColors.blue,
          backgroundColor: Color(0xFFEAF1FF),
        );
      case ParentNotificationType.delay:
        return const _NotificationTileStyle(
          icon: Icons.schedule_outlined,
          iconColor: ParentUiColors.warning,
          backgroundColor: Color(0xFFFFF7E6),
        );
      case ParentNotificationType.emergency:
        return const _NotificationTileStyle(
          icon: Icons.warning_amber_rounded,
          iconColor: ParentUiColors.danger,
          backgroundColor: Color(0xFFFFEAEA),
        );
      case ParentNotificationType.general:
        return const _NotificationTileStyle(
          icon: Icons.notifications_none_rounded,
          iconColor: ParentUiColors.orange,
          backgroundColor: ParentUiColors.lightOrange,
        );
    }
  }
}

enum ParentNotificationType { boarded, dropped, delay, emergency, general }

class _NotificationTileStyle {
  const _NotificationTileStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}
