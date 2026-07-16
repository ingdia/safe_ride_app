enum NotificationType { sos, arrival, absence, general }

extension NotificationTypeX on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.sos:
        return 'sos';
      case NotificationType.arrival:
        return 'arrival';
      case NotificationType.absence:
        return 'absence';
      case NotificationType.general:
        return 'general';
    }
  }
}

class NotificationModel {
  final String notificationId;
  final String recipientId;
  final NotificationType type;
  final String message;
  final String? relatedId;
  final bool isRead;
  final DateTime timestamp;

  const NotificationModel({
    required this.notificationId,
    required this.recipientId,
    required this.type,
    required this.message,
    this.relatedId,
    required this.isRead,
    required this.timestamp,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notificationId: notificationId,
      recipientId: recipientId,
      type: type,
      message: message,
      relatedId: relatedId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
    );
  }
}
