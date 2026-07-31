import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import 'parent_firestore_fields.dart';

/// Persists notification records to Firestore's `notifications` collection
/// so they show up in the parent's in-app notification history. Actual
/// on-device alerts are separately handled by [NotificationService] — this
/// writer is only responsible for the persisted record, not the local push.
class ParentNotificationWriter {
  ParentNotificationWriter({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> createNotification({
    required String parentId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _firestore.collection(FirebaseCollections.notifications).add({
      ParentNotificationFields.parentId: parentId,
      ParentNotificationFields.title: title,
      ParentNotificationFields.message: message,
      ParentNotificationFields.type: type,
      ParentNotificationFields.isRead: false,
      ParentNotificationFields.source: 'saferide',
      ParentNotificationFields.createdAt: FieldValue.serverTimestamp(),
    });
  }
}
