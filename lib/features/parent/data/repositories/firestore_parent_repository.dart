import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/parent_child_entity.dart';
import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_profile_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../datasources/parent_firestore_fields.dart';
import '../datasources/parent_firestore_paths.dart';
import '../models/parent_child_firestore_model.dart';
import '../models/parent_notification_firestore_model.dart';
import '../models/parent_profile_firestore_model.dart';
import '../models/parent_trip_firestore_model.dart';
import 'mock_parent_repository.dart';
import 'parent_repository.dart';

class FirestoreParentRepository implements ParentRepository {
  FirestoreParentRepository({
    FirebaseFirestore? firestore,
    this.activeTripId = 'trip_001',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String activeTripId;

  final MockParentRepository _fallbackRepository = const MockParentRepository();

  @override
  Future<ParentDashboardEntity> getDashboard() {
    return _fallbackRepository.getDashboard();
  }

  @override
  Future<ParentTripEntity> getLiveTrip() async {
    final snapshot = await _firestore
        .collection(ParentFirestorePaths.trips)
        .doc(activeTripId)
        .get();

    if (!snapshot.exists) {
      return ParentTripFirestoreModel.fallback(activeTripId);
    }

    return ParentTripFirestoreModel.fromSnapshot(snapshot);
  }

  @override
  Stream<ParentTripEntity> watchLiveTrip() {
    return _firestore
        .collection(ParentFirestorePaths.trips)
        .doc(activeTripId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return ParentTripFirestoreModel.fallback(activeTripId);
          }

          return ParentTripFirestoreModel.fromSnapshot(snapshot);
        });
  }

  @override
  Future<List<ParentNotificationEntity>> getNotifications() async {
    final snapshot = await _firestore
        .collection(ParentFirestorePaths.notifications)
        .where(
          ParentNotificationFields.parentId,
          isEqualTo: ParentFirestorePaths.activeParentId,
        )
        .get();

    return snapshot.docs
        .map(ParentNotificationFirestoreModel.fromSnapshot)
        .toList();
  }

  @override
  Stream<List<ParentNotificationEntity>> watchNotifications() {
    return _firestore
        .collection(ParentFirestorePaths.notifications)
        .where(
          ParentNotificationFields.parentId,
          isEqualTo: ParentFirestorePaths.activeParentId,
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(ParentNotificationFirestoreModel.fromSnapshot)
              .toList();
        });
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection(ParentFirestorePaths.notifications)
        .doc(notificationId)
        .set({
          ParentNotificationFields.isRead: true,
          ParentNotificationFields.readAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    final snapshot = await _firestore
        .collection(ParentFirestorePaths.notifications)
        .where(
          ParentNotificationFields.parentId,
          isEqualTo: ParentFirestorePaths.activeParentId,
        )
        .where(ParentNotificationFields.isRead, isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.set(document.reference, {
        ParentNotificationFields.isRead: true,
        ParentNotificationFields.readAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<ParentProfileEntity> getParentProfile() async {
    final snapshot = await _firestore
        .collection(ParentFirestorePaths.parents)
        .doc(ParentFirestorePaths.activeParentId)
        .get();

    if (!snapshot.exists) {
      return ParentProfileFirestoreModel.fallback(
        ParentFirestorePaths.activeParentId,
      );
    }

    return ParentProfileFirestoreModel.fromSnapshot(snapshot);
  }

  @override
  Stream<ParentProfileEntity> watchParentProfile() {
    return _firestore
        .collection(ParentFirestorePaths.parents)
        .doc(ParentFirestorePaths.activeParentId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return ParentProfileFirestoreModel.fallback(
              ParentFirestorePaths.activeParentId,
            );
          }

          return ParentProfileFirestoreModel.fromSnapshot(snapshot);
        });
  }

  @override
  Future<void> updateParentProfile(ParentProfileEntity profile) async {
    await _firestore
        .collection(ParentFirestorePaths.parents)
        .doc(profile.parentId)
        .set(
          ParentProfileFirestoreModel.toUpdateMap(profile),
          SetOptions(merge: true),
        );
  }

  @override
  Stream<List<ParentChildEntity>> watchChildren() {
    return _firestore
        .collection(
          ParentFirestorePaths.parentChildren(
            ParentFirestorePaths.activeParentId,
          ),
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(ParentChildFirestoreModel.fromSnapshot)
              .toList();
        });
  }

  @override
  Future<void> addChild(ParentChildEntity child) async {
    await _firestore
        .collection(
          ParentFirestorePaths.parentChildren(
            ParentFirestorePaths.activeParentId,
          ),
        )
        .add(ParentChildFirestoreModel.toCreateMap(child));
  }

  @override
  Future<void> updateChild(ParentChildEntity child) async {
    await _firestore
        .collection(
          ParentFirestorePaths.parentChildren(
            ParentFirestorePaths.activeParentId,
          ),
        )
        .doc(child.id)
        .set(
          ParentChildFirestoreModel.toUpdateMap(child),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteChild(String childId) async {
    await _firestore
        .collection(
          ParentFirestorePaths.parentChildren(
            ParentFirestorePaths.activeParentId,
          ),
        )
        .doc(childId)
        .delete();
  }
}
