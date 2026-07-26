import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_parent_repository.dart';
import '../../data/datasources/parent_demo_trip_seed.dart';
import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../../data/repositories/parent_repository.dart';

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
  final notificationsState = ref.watch(parentNotificationsProvider);

  return notificationsState.maybeWhen(
    data: (notifications) {
      return notifications.where((notification) => !notification.isRead).length;
    },
    orElse: () => 0,
  );
});
