import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';

final List<NotificationModel> _seedNotifications = [
  NotificationModel(
    notificationId: 'notif-1',
    recipientId: 'user-admin-1',
    type: NotificationType.arrival,
    message: 'Bus #07 delayed by 8 minutes on Route B',
    isRead: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  NotificationModel(
    notificationId: 'notif-2',
    recipientId: 'user-admin-1',
    type: NotificationType.general,
    message: 'Sarah Johnson started route at 7:45 AM',
    isRead: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  NotificationModel(
    notificationId: 'notif-3',
    recipientId: 'user-admin-1',
    type: NotificationType.arrival,
    message: 'All morning routes successfully completed',
    isRead: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  NotificationModel(
    notificationId: 'notif-4',
    recipientId: 'user-admin-1',
    type: NotificationType.general,
    message: 'Heavy rain expected this afternoon',
    isRead: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  NotificationModel(
    notificationId: 'notif-5',
    recipientId: 'user-admin-1',
    type: NotificationType.general,
    message: 'Mike Davis assigned to Bus #15',
    isRead: true,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

class NotificationsController extends Notifier<List<NotificationModel>> {
  @override
  List<NotificationModel> build() {
    return _seedNotifications;
  }

  void markAsRead(String notificationId) {
    state = [
      for (final n in state)
        if (n.notificationId == notificationId) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, List<NotificationModel>>(
  NotificationsController.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});
