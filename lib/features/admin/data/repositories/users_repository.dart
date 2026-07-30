import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/user_model.dart';

class UsersRepository {
  UsersRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirebaseCollections.users);

  Future<List<UserModel>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snap = await _col.where(FieldPath.documentId, whereIn: ids).get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }

  /// Streams all users belonging to [schoolId].
  Stream<List<UserModel>> streamBySchool(String schoolId) {
    return _col
        .where('school_id', isEqualTo: schoolId)
        .snapshots()
        .map((snap) => snap.docs.map(UserModel.fromFirestore).toList());
  }

  Future<void> updateApprovalStatus(
    String userId,
    DriverApprovalStatus status,
  ) async {
    await _col.doc(userId).update({'approval_status': status.value});
  }
}
