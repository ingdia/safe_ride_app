import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_parent_repository.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../../domain/entities/parent_profile_entity.dart';
import '../../data/repositories/parent_repository.dart';
import '../../domain/entities/parent_child_entity.dart';
import '../../data/datasources/parent_notification_writer.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return FirestoreParentRepository();
});

final parentLiveTripStreamProvider = StreamProvider<ParentTripEntity?>((ref) {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.watchLiveTrip();
});

final parentUnreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(parentNotificationsStreamProvider);

  return notificationsState.maybeWhen(
    data: (notifications) {
      return notifications.where((notification) => !notification.isRead).length;
    },
    orElse: () => 0,
  );
});

final parentProfileStreamProvider = StreamProvider<ParentProfileEntity>((ref) {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.watchParentProfile();
});

final parentChildrenStreamProvider = StreamProvider<List<ParentChildEntity>>((
  ref,
) {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.watchChildren();
});

final parentNotificationWriterProvider = Provider<ParentNotificationWriter>((
  ref,
) {
  return ParentNotificationWriter();
});

final parentNotificationsStreamProvider =
    StreamProvider<List<ParentNotificationEntity>>((ref) {
      final repository = ref.watch(parentRepositoryProvider);
      return repository.watchNotifications();
    });
