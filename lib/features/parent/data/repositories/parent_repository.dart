import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';

abstract class ParentRepository {
  Future<ParentDashboardEntity> getDashboard();

  Future<ParentTripEntity> getLiveTrip();

  Future<List<ParentNotificationEntity>> getNotifications();

  Future<void> markNotificationAsRead(String notificationId);
}
