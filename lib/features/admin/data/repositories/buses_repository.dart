import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/bus_model.dart';

class BusesRepository {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<BusModel>> watch(String schoolId) {
    return _firestore
        .collection(FirebaseCollections.buses)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((snap) => snap.docs.map(BusModel.fromDoc).toList());
  }

  Future<void> add(BusModel bus) {
    return _firestore.collection(FirebaseCollections.buses).add(bus.toCreateMap());
  }

  Future<void> update(BusModel bus) {
    return _firestore
        .collection(FirebaseCollections.buses)
        .doc(bus.busId)
        .set(bus.toCreateMap(), SetOptions(merge: true));
  }

  Future<void> delete(String busId) {
    return _firestore.collection(FirebaseCollections.buses).doc(busId).delete();
  }
}
