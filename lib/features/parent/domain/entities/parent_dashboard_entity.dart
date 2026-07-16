import 'parent_notification_entity.dart';
import 'parent_trip_entity.dart';

class ParentDashboardEntity {
  const ParentDashboardEntity({
    required this.parentName,
    required this.childName,
    required this.schoolName,
    required this.grade,
    required this.trip,
    required this.recentNotifications,
    required this.unreadNotifications,
    required this.safeUpdates,
    required this.importantAlerts,
  });

  final String parentName;
  final String childName;
  final String schoolName;
  final String grade;
  final ParentTripEntity trip;
  final List<ParentNotificationEntity> recentNotifications;
  final int unreadNotifications;
  final int safeUpdates;
  final int importantAlerts;
}
