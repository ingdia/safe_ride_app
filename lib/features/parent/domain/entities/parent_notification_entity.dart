enum ParentAlertType { boarded, dropped, delay, emergency, general }

class ParentNotificationEntity {
  const ParentNotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final ParentAlertType type;
  final bool isRead;
}
