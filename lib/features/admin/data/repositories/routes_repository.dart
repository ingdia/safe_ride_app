import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/route_model.dart';

class RoutesRepository {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<RouteModel>> watch(String schoolId) {
    return _firestore
        .collection(FirebaseCollections.routes)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((snap) => snap.docs.map(RouteModel.fromDoc).toList());
  }

  Future<void> add(RouteModel route) {
    return _firestore.collection(FirebaseCollections.routes).add(route.toCreateMap());
  }

  Future<void> update(RouteModel route) {
    return _firestore
        .collection(FirebaseCollections.routes)
        .doc(route.routeId)
        .set(route.toCreateMap(), SetOptions(merge: true));
  }

  Future<void> delete(String routeId) {
    return _firestore.collection(FirebaseCollections.routes).doc(routeId).delete();
  }
}
