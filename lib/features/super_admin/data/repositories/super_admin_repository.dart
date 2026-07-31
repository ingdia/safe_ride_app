import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../admin/data/models/school_model.dart';
import '../../../admin/data/models/user_model.dart';

/// Cross-school management for the super admin. Account creation uses the
/// same secondary-[FirebaseApp] trick as driver creation — no backend, so it
/// has to stay entirely client-side to remain on the Spark (free) plan.
class SuperAdminRepository {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<SchoolModel>> watchSchools() {
    return _firestore
        .collection(FirebaseCollections.schools)
        .snapshots()
        .map((snap) => snap.docs.map(SchoolModel.fromDoc).toList());
  }

  Future<void> createSchool({required String name, required String address}) {
    return _firestore.collection(FirebaseCollections.schools).add({
      'name': name.trim(),
      'address': address.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSchool(SchoolModel school) {
    return _firestore
        .collection(FirebaseCollections.schools)
        .doc(school.schoolId)
        .set(school.toMap(), SetOptions(merge: true));
  }

  Stream<List<UserModel>> watchAdmins(String schoolId) {
    return _firestore
        .collection(FirebaseCollections.users)
        .where('role', isEqualTo: 'admin')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((snap) => snap.docs.map(UserModel.fromDoc).toList());
  }

  Future<void> createSchoolAdmin({
    required String schoolId,
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'schoolAdminCreation-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final adminUser = credential.user!;
      await adminUser.updateDisplayName(name.trim());

      try {
        await _firestore.collection(FirebaseCollections.users).doc(adminUser.uid).set({
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'role': 'admin',
          'schoolId': schoolId,
          'onboardingComplete': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Same reasoning as DriversRepository.createDriver: don't leave an
        // Auth account with no matching Firestore doc — that email would be
        // permanently stuck on every retry otherwise.
        await adminUser.delete();
        rethrow;
      }

      await secondaryAuth.signOut();
    } finally {
      await secondaryApp.delete();
    }
  }
}
