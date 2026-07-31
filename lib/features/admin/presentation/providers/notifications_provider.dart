import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../shared/models/student_entity.dart';
import '../../../../shared/models/trip_entity.dart';
import '../../data/models/notification_model.dart';
import 'admin_session_provider.dart';
import 'school_students_provider.dart';

/// Real-time activity feed derived from actual school data — pending
/// approvals and trip lifecycle events — not a fake seed list. There's no
/// separate "admin notifications" collection (that would mean every driver/
/// admin action writing an extra document with no backend to do it for
/// them); this is computed client-side from streams already in use
/// elsewhere, which keeps it fully live without adding writes anywhere.
final _schoolTripsForFeedProvider = StreamProvider.autoDispose<List<TripEntity>>((ref) {
  final schoolId = ref.watch(adminSchoolIdProvider);
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.trips)
      .where('schoolId', isEqualTo: schoolId)
      .snapshots()
      .map((snap) => snap.docs.map(TripEntity.fromDoc).toList());
});

final _activityFeedProvider = Provider<List<NotificationModel>>((ref) {
  final students = ref.watch(schoolStudentsProvider).maybeWhen(
        data: (v) => v,
        orElse: () => const <StudentEntity>[],
      );
  final trips = ref.watch(_schoolTripsForFeedProvider).maybeWhen(
        data: (v) => v,
        orElse: () => const <TripEntity>[],
      );

  final items = <NotificationModel>[];

  for (final student in students) {
    if (student.status == StudentStatus.pending) {
      items.add(NotificationModel(
        notificationId: 'student-pending-${student.id}',
        recipientId: 'admin',
        type: NotificationType.general,
        message: '${student.name} is awaiting approval.',
        relatedId: student.id,
        isRead: false,
        timestamp: DateTime.now(),
      ));
    } else if (student.status == StudentStatus.approved && student.busNumber != null) {
      items.add(NotificationModel(
        notificationId: 'student-assigned-${student.id}',
        recipientId: 'admin',
        type: NotificationType.general,
        message: '${student.name} assigned to Bus ${student.busNumber}.',
        relatedId: student.id,
        isRead: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  for (final trip in trips) {
    if (trip.status == TripStatus.inProgress && trip.startedAt != null) {
      items.add(NotificationModel(
        notificationId: 'trip-started-${trip.id}',
        recipientId: 'admin',
        type: NotificationType.general,
        message: 'Bus ${trip.busId} started route.',
        relatedId: trip.id,
        isRead: false,
        timestamp: trip.startedAt!,
      ));
    } else if (trip.status == TripStatus.completed && trip.completedAt != null) {
      items.add(NotificationModel(
        notificationId: 'trip-completed-${trip.id}',
        recipientId: 'admin',
        type: NotificationType.arrival,
        message: 'Bus ${trip.busId} completed its route.',
        relatedId: trip.id,
        isRead: false,
        timestamp: trip.completedAt!,
      ));
    }
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
});

class NotificationsController extends Notifier<List<NotificationModel>> {
  final Set<String> _readIds = {};

  @override
  List<NotificationModel> build() {
    final feed = ref.watch(_activityFeedProvider);
    return feed.map((n) => n.copyWith(isRead: _readIds.contains(n.notificationId))).toList();
  }

  void markAsRead(String notificationId) {
    _readIds.add(notificationId);
    state = [
      for (final n in state)
        if (n.notificationId == notificationId) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    _readIds.addAll(state.map((n) => n.notificationId));
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, List<NotificationModel>>(
  NotificationsController.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});
