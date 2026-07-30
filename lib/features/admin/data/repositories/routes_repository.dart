import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/route_model.dart';

/// Staleness threshold: routes with no bus assigned for this many days
/// are considered stale. Configurable here without touching call sites.
const int kRouteStaleThresholdDays = 30;

class RoutesRepository {
  RoutesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirebaseCollections.routes);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  Future<List<RouteModel>> getAll(String schoolId) async {
    final snap = await _col
        .where('school_id', isEqualTo: schoolId)
        .orderBy('created_at', descending: false)
        .get();
    return snap.docs.map(RouteModel.fromFirestore).toList();
  }

  Stream<List<RouteModel>> stream(String schoolId) {
    return _col
        .where('school_id', isEqualTo: schoolId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(RouteModel.fromFirestore).toList());
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  Future<void> add(RouteModel route) async {
    await _col.doc(route.routeId).set(route.toFirestore());
  }

  Future<void> update(RouteModel route) async {
    await _col.doc(route.routeId).update(route.toFirestore());
  }

  Future<void> delete(String routeId) async {
    await _col.doc(routeId).delete();
  }

  // ---------------------------------------------------------------------------
  // Stale-data cleanup
  // ---------------------------------------------------------------------------

  /// Deletes routes that have no bus assigned AND were created more than
  /// [kRouteStaleThresholdDays] days ago.
  /// Returns the number of documents deleted.
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
