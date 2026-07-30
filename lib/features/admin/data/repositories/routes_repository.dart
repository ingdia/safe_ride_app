import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/route_model.dart';

const int kRouteStaleThresholdDays = 30;

class RoutesRepository {
  RoutesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirebaseCollections.routes);

  Stream<List<RouteModel>> stream(String schoolId) {
    return _col
        .where('school_id', isEqualTo: schoolId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(RouteModel.fromFirestore).toList());
  }

  Future<void> add(RouteModel route) async {
    await _col.doc(route.routeId).set(route.toFirestore());
  }

  Future<void> update(RouteModel route) async {
    await _col.doc(route.routeId).update(route.toFirestore());
  }

  Future<void> delete(String routeId) async {
    await _col.doc(routeId).delete();
  }

  Future<int> deleteStale(String schoolId) async {
    final cutoff = DateTime.now()
        .subtract(const Duration(days: kRouteStaleThresholdDays));
    final snap = await _col
        .where('school_id', isEqualTo: schoolId)
        .where('bus_id', isEqualTo: '')
        .where('created_at', isLessThan: Timestamp.fromDate(cutoff))
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return snap.docs.length;
  }
}
