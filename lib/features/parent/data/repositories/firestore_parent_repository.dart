import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../../data/repositories/parent_repository.dart';
import '../models/parent_trip_firestore_model.dart';
import 'mock_parent_repository.dart';

class FirestoreParentRepository implements ParentRepository {
  FirestoreParentRepository({
    FirebaseFirestore? firestore,
    this.activeTripId = 'trip_001',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String activeTripId;

  static const String tripsCollection = 'trips';

  final MockParentRepository _fallbackRepository = const MockParentRepository();

  @override
  Future<ParentDashboardEntity> getDashboard() {
    return _fallbackRepository.getDashboard();
  }

  @override
  Future<ParentTripEntity> getLiveTrip() async {
    final snapshot = await _firestore
        .collection(tripsCollection)
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
        .collection(tripsCollection)
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
  Future<List<ParentNotificationEntity>> getNotifications() {
    return _fallbackRepository.getNotifications();
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) {
    return _fallbackRepository.markNotificationAsRead(notificationId);
  }
}
