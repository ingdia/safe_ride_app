import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../../domain/entities/parent_profile_entity.dart';

abstract class ParentRepository {
  Future<ParentDashboardEntity> getDashboard();

  Future<ParentTripEntity> getLiveTrip();

  Future<List<ParentNotificationEntity>> getNotifications();

  Stream<ParentTripEntity> watchLiveTrip();

  Future<void> markNotificationAsRead(String notificationId);

  Future<ParentProfileEntity> getParentProfile();

  Stream<ParentProfileEntity> watchParentProfile();

  Future<void> updateParentProfile(ParentProfileEntity profile);
}
