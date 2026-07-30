import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/student_model.dart';

class StudentsRepository {
  StudentsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<StudentModel>> stream(String schoolId) {
    return _firestore
        .collection(FirebaseCollections.students)
        .where('school_id', isEqualTo: schoolId)
        .snapshots()
        .map((snap) => snap.docs.map(StudentModel.fromFirestore).toList());
  }
}
