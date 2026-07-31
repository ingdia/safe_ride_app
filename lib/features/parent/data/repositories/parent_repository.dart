import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../../domain/entities/parent_child_entity.dart';
import '../../domain/entities/parent_profile_entity.dart';

abstract class ParentRepository {
  /// Live view of the currently authenticated parent's approved child with
  /// the most relevant trip in progress. Returns null if no child has been
  /// approved yet, or no trip is currently active.
  Stream<ParentTripEntity?> watchLiveTrip();

  Future<ParentProfileEntity> getParentProfile();

  Stream<ParentProfileEntity> watchParentProfile();

  Future<void> updateParentProfile(ParentProfileEntity profile);

  Stream<List<ParentChildEntity>> watchChildren();

  Future<void> addChild({
    required String fullName,
    required String grade,
    required String schoolId,
    required String requestedStop,
  });

  Future<void> updateChild(ParentChildEntity child);

  Future<void> deleteChild(String childId);

  Stream<List<ParentNotificationEntity>> watchNotifications();

  Future<void> markNotificationAsRead(String notificationId);

  Future<void> markAllNotificationsAsRead();
}
