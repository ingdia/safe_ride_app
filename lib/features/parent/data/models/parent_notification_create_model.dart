class ParentNotificationCreateModel {
  const ParentNotificationCreateModel({
    required this.parentId,
    required this.title,
    required this.message,
    required this.type,
  });

  final String parentId;
  final String title;
  final String message;
  final String type;
}
