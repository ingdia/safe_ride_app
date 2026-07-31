import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/parent_child_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import 'parent_data_providers.dart';

/// Diffs the parent's live Firestore streams (children/trip) and fires the
/// matching local notification — plus a persisted record via
/// [ParentNotificationWriter] — on each meaningful transition:
///
/// - student pending -> approved (+ bus assigned, since SafeRide assigns
///   both in the same admin action)
/// - trip not-started -> in-progress ("driver started the trip")
/// - bus within ~10 minutes of the next stop
/// - this child boarded / dropped off
/// - trip -> completed
///
/// All local-only via [NotificationService] (flutter_local_notifications) —
/// no FCM/push, consistent with the Firebase Spark (free) plan.
///
/// Watch this provider once for the duration of the parent's session (e.g.
/// from `ParentNavigationShell`) so the `ref.listen` subscriptions below
/// stay alive; the first emission on each stream only establishes a
/// baseline and never fires a notification for state that already existed
/// before the app was opened.
final parentNotificationTriggerProvider = Provider<void>((ref) {
  List<ParentChildEntity>? previousChildren;
  ParentTripEntity? previousTrip;

  ref.listen<AsyncValue<List<ParentChildEntity>>>(
    parentChildrenStreamProvider,
    (previous, next) {
      next.whenData((children) {
        final before = previousChildren;
        if (before != null) {
          for (final child in children) {
            final match = before.where((c) => c.id == child.id).toList();
            final wasApproved = match.isNotEmpty && match.first.isApproved;
            if (!wasApproved && child.isApproved) {
              _notifyAndPersist(
                ref,
                title: 'Student Approved',
                body: '${child.fullName} has been approved by the school.',
                type: 'general',
                localCall: () => NotificationService.instance.showStudentApproved(child.fullName),
              );
              if (child.isAssignedToBus) {
                final busLabel = child.busNumber ?? 'a bus';
                _notifyAndPersist(
                  ref,
                  title: 'Bus Assigned',
                  body: '${child.fullName} has been assigned to $busLabel.',
                  type: 'general',
                  localCall: () => NotificationService.instance.showBusAssigned(busLabel),
                );
              }
            }
          }
        }
        previousChildren = children;
      });
    },
    fireImmediately: true,
  );

  ref.listen<AsyncValue<ParentTripEntity?>>(
    parentLiveTripStreamProvider,
    (previous, next) {
      next.whenData((trip) {
        final before = previousTrip;
        if (before != null && trip != null) {
          if (before.status != ParentTripStatus.onTime && trip.status == ParentTripStatus.onTime) {
            _notifyAndPersist(
              ref,
              title: 'Trip Started',
              body: '${trip.driverName} has started the route for ${trip.childName}.',
              type: 'general',
              localCall: () => NotificationService.instance.showTripStarted(trip.driverName),
            );
          }

          final wasApproaching = before.minutesAway >= 0 && before.minutesAway <= 10;
          final isApproaching = trip.minutesAway >= 0 && trip.minutesAway <= 10;
          if (!wasApproaching && isApproaching) {
            _notifyAndPersist(
              ref,
              title: 'Bus Approaching',
              body: '${trip.busNumber} is about 10 minutes away.',
              type: 'general',
              localCall: () => NotificationService.instance.showBusApproaching(),
            );
          }

          if (before.studentEvent != 'boarded' && trip.studentEvent == 'boarded') {
            _notifyAndPersist(
              ref,
              title: 'Boarded',
              body: '${trip.childName} has boarded ${trip.busNumber}.',
              type: 'boarded',
              localCall: () => NotificationService.instance.showStudentBoarded(trip.childName),
            );
          }

          if (before.studentEvent != 'droppedOff' && trip.studentEvent == 'droppedOff') {
            _notifyAndPersist(
              ref,
              title: 'Dropped Off',
              body: '${trip.childName} has been dropped off safely.',
              type: 'dropped',
              localCall: () => NotificationService.instance.showStudentDroppedOff(trip.childName),
            );
          }

          if (before.status != ParentTripStatus.completed && trip.status == ParentTripStatus.completed) {
            _notifyAndPersist(
              ref,
              title: 'Trip Completed',
              body: "Today's trip has been completed.",
              type: 'general',
              localCall: () => NotificationService.instance.showTripCompleted(),
            );
          }
        }
        previousTrip = trip;
      });
    },
    fireImmediately: true,
  );
});

void _notifyAndPersist(
  Ref ref, {
  required String title,
  required String body,
  required String type,
  required Future<void> Function() localCall,
}) {
  localCall();

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  ref.read(parentNotificationWriterProvider).createNotification(
        parentId: uid,
        title: title,
        message: body,
        type: type,
      );
}
