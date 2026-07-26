import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/parent_notification_create_model.dart';
import 'parent_firestore_fields.dart';
import 'parent_firestore_paths.dart';

class ParentNotificationWriter {
  ParentNotificationWriter({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> createNotification(
    ParentNotificationCreateModel notification,
  ) async {
    await _firestore.collection(ParentFirestorePaths.notifications).add({
      ParentNotificationFields.parentId: notification.parentId,
      ParentNotificationFields.title: notification.title,
      ParentNotificationFields.message: notification.message,
      ParentNotificationFields.type: notification.type,
      ParentNotificationFields.isRead: false,
      ParentNotificationFields.source: 'parent_backend_integration',
      ParentNotificationFields.createdAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> createBoardedNotification({
    required String childName,
    required String busNumber,
    required String stopName,
  }) {
    return createNotification(
      ParentNotificationCreateModel(
        parentId: ParentFirestorePaths.activeParentId,
        title: 'Student boarded',
        message: '$childName boarded $busNumber at $stopName.',
        type: 'boarded',
      ),
    );
  }

  Future<void> createBusMovedNotification({
    required String busNumber,
    required String currentStop,
    required String nextStop,
  }) {
    return createNotification(
      ParentNotificationCreateModel(
        parentId: ParentFirestorePaths.activeParentId,
        title: 'Bus location updated',
        message: '$busNumber is now at $currentStop. Next stop: $nextStop.',
        type: 'general',
      ),
    );
  }

  Future<void> createDelayNotification({
    required String busNumber,
    required String eta,
  }) {
    return createNotification(
      ParentNotificationCreateModel(
        parentId: ParentFirestorePaths.activeParentId,
        title: 'Bus delayed',
        message: '$busNumber is delayed. New estimated arrival time is $eta.',
        type: 'delay',
      ),
    );
  }

  Future<void> createArrivalNotification({
    required String childName,
    required String schoolName,
  }) {
    return createNotification(
      ParentNotificationCreateModel(
        parentId: ParentFirestorePaths.activeParentId,
        title: 'Safe arrival',
        message: '$childName arrived safely at $schoolName.',
        type: 'dropped',
      ),
    );
  }
}
