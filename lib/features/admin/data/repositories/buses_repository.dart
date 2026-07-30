import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/bus_model.dart';

/// Staleness threshold: buses with no driver assigned for this many days
/// are considered stale. Configurable here without touching call sites.
const int kBusStaleThresholdDays = 30;

class BusesRepository {
  BusesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirebaseCollections.buses);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Fetches all buses for [schoolId] once (no stream).
  Future<List<BusModel>> getAll(String schoolId) async {
    final snap = await _col
        .where('school_id', isEqualTo: schoolId)
        .orderBy('created_at', descending: false)
        .get();
    return snap.docs.map(BusModel.fromFirestore).toList();
  }

  Stream<List<BusModel>> stream(String schoolId) {
    return _col
        .where('school_id', isEqualTo: schoolId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(BusModel.fromFirestore).toList());
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  Future<void> add(BusModel bus) async {
    await _col.doc(bus.busId).set(bus.toFirestore());
  }

  Future<void> update(BusModel bus) async {
    await _col.doc(bus.busId).update(bus.toFirestore());
  }

  Future<void> delete(String busId) async {
    await _col.doc(busId).delete();
  }

  // ---------------------------------------------------------------------------
  // Stale-data cleanup
  // ---------------------------------------------------------------------------

  /// Deletes buses that have no driver assigned AND were created more than
  /// [kBusStaleThresholdDays] days ago.
  /// Returns the number of documents deleted.
  Future<int> deleteStale(String schoolId) async {
    final cutoff = DateTime.now()
        .subtract(const Duration(days: kBusStaleThresholdDays));

    final snap = await _col
        .where('school_id', isEqualTo: schoolId)
        .where('driver_id', isEqualTo: '')
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
