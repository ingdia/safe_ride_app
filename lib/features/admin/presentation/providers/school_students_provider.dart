import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../shared/models/student_entity.dart';
import 'admin_session_provider.dart';

/// All students (any status) belonging to the admin's school.
final schoolStudentsProvider = StreamProvider<List<StudentEntity>>((ref) {
  final schoolId = ref.watch(adminSchoolIdProvider);
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.students)
      .where('schoolId', isEqualTo: schoolId)
      .snapshots()
      .map((snap) => snap.docs.map(StudentEntity.fromDoc).toList());
});

final pendingStudentsProvider = Provider<List<StudentEntity>>((ref) {
  final studentsAsync = ref.watch(schoolStudentsProvider);
  return studentsAsync.maybeWhen(
    data: (students) => students.where((s) => s.status == StudentStatus.pending).toList(),
    orElse: () => const [],
  );
});

class StudentApprovalActions {
  StudentApprovalActions(this._firestore);
  final FirebaseFirestore _firestore;

  Future<void> approve({
    required String studentId,
    required String busId,
    required String busNumber,
    required String routeId,
    required String stopName,
    required String driverName,
    required String driverPhone,
  }) async {
    await _firestore.collection(FirebaseCollections.students).doc(studentId).set({
      'status': 'approved',
      'busId': busId,
      'busNumber': busNumber,
      'routeId': routeId,
      'stopName': stopName,
      'driverName': driverName,
      'driverPhone': driverPhone,
    }, SetOptions(merge: true));
  }

  Future<void> reject(String studentId) async {
    await _firestore.collection(FirebaseCollections.students).doc(studentId).set({
      'status': 'rejected',
    }, SetOptions(merge: true));
  }
}

final studentApprovalActionsProvider = Provider<StudentApprovalActions>((ref) {
  return StudentApprovalActions(FirebaseFirestore.instance);
});
