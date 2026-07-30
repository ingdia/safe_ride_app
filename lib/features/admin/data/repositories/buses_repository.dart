import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/bus_model.dart';

class BusesRepository {
  BusesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirebaseCollections.buses);

  Stream<List<BusModel>> stream(String schoolId) {
    return _col
        .where('school_id', isEqualTo: schoolId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(BusModel.fromFirestore).toList());
  }

  Future<void> add(BusModel bus) async {
    await _col.doc(bus.busId).set(bus.toFirestore());
  }

  Future<void> update(BusModel bus) async {
    await _col.doc(bus.busId).update(bus.toFirestore());
  }

  Future<void> delete(String busId) async {
    await _col.doc(busId).delete();
  }

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
