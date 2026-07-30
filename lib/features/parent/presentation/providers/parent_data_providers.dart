import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_parent_repository.dart';
import '../../data/datasources/parent_demo_trip_seed.dart';
import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../../domain/entities/parent_profile_entity.dart';
import '../../data/repositories/parent_repository.dart';
import '../../domain/entities/parent_child_entity.dart';
import '../../data/datasources/parent_notification_writer.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return FirestoreParentRepository();
});

final parentDashboardProvider = FutureProvider<ParentDashboardEntity>((
  ref,
) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getDashboard();
});

final parentLiveTripProvider = FutureProvider<ParentTripEntity>((ref) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getLiveTrip();
});

final parentLiveTripStreamProvider = StreamProvider<ParentTripEntity>((ref) {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.watchLiveTrip();
});

final parentNotificationsProvider =
    FutureProvider<List<ParentNotificationEntity>>((ref) async {
      final repository = ref.watch(parentRepositoryProvider);
      return repository.getNotifications();
    });

final parentDemoTripSeedProvider = Provider<ParentDemoTripSeed>((ref) {
  return ParentDemoTripSeed();
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

final parentProfileProvider = FutureProvider<ParentProfileEntity>((ref) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getParentProfile();
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
