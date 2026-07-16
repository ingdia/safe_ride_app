import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_parent_repository.dart';
import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../../data/repositories/parent_repository.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return const MockParentRepository();
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

final parentNotificationsProvider =
    FutureProvider<List<ParentNotificationEntity>>((ref) async {
      final repository = ref.watch(parentRepositoryProvider);
      return repository.getNotifications();
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
