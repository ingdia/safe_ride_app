import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_notification_entity.dart';

enum ParentNotificationFilter { all, unread }

class ParentNotificationCenterState {
  const ParentNotificationCenterState({
    required this.notifications,
    required this.selectedFilter,
  });

  final List<ParentNotificationEntity> notifications;
  final ParentNotificationFilter selectedFilter;

  int get totalCount {
    return notifications.length;
  }

  int get unreadCount {
    return notifications.where((notification) => !notification.isRead).length;
  }

  List<ParentNotificationEntity> get visibleNotifications {
    switch (selectedFilter) {
      case ParentNotificationFilter.all:
        return notifications;
      case ParentNotificationFilter.unread:
        return notifications
            .where((notification) => !notification.isRead)
            .toList();
    }
  }

  ParentNotificationCenterState copyWith({
    List<ParentNotificationEntity>? notifications,
    ParentNotificationFilter? selectedFilter,
  }) {
    return ParentNotificationCenterState(
      notifications: notifications ?? this.notifications,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

final parentNotificationCenterProvider =
    NotifierProvider<
      ParentNotificationCenterController,
      ParentNotificationCenterState
    >(ParentNotificationCenterController.new);

class ParentNotificationCenterController
    extends Notifier<ParentNotificationCenterState> {
  @override
  ParentNotificationCenterState build() {
    return const ParentNotificationCenterState(
      selectedFilter: ParentNotificationFilter.all,
      notifications: [
        ParentNotificationEntity(
          id: 'notification_001',
          title: 'Bus approaching',
          message: 'Bus #12 is 5 minutes away from your stop at Remera.',
          time: '2 min ago',
          type: ParentAlertType.general,
          isRead: false,
        ),
        ParentNotificationEntity(
          id: 'notification_002',
          title: 'Check-in confirmed',
          message: 'Ineza Uwase checked in to Bus #12 at Kacyiru.',
          time: '15 min ago',
          type: ParentAlertType.boarded,
          isRead: false,
        ),
        ParentNotificationEntity(
          id: 'notification_003',
          title: 'Slight delay',
          message: 'Route delayed by 3 minutes due to traffic near Giporoso.',
          time: '1 hour ago',
          type: ParentAlertType.delay,
          isRead: true,
        ),
        ParentNotificationEntity(
          id: 'notification_004',
          title: 'Route update',
          message: 'Temporary route change near Kimironko Road.',
          time: '2 hours ago',
          type: ParentAlertType.general,
          isRead: true,
        ),
        ParentNotificationEntity(
          id: 'notification_005',
          title: 'Safe arrival',
          message: 'Ineza Uwase arrived safely at Kigali Parents School.',
          time: 'Yesterday',
          type: ParentAlertType.dropped,
          isRead: true,
        ),
      ],
    );
  }

  void selectFilter(ParentNotificationFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void markAsRead(String notificationId) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id != notificationId) {
        return notification;
      }

      return ParentNotificationEntity(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        time: notification.time,
        type: notification.type,
        isRead: true,
      );
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((notification) {
      return ParentNotificationEntity(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        time: notification.time,
        type: notification.type,
        isRead: true,
      );
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }
}
