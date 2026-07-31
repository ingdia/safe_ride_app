import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/user_model.dart';

/// Drivers can't self-register — only an admin creates their account. Since
/// the app has no backend (Spark plan, no Cloud Functions), account creation
/// runs entirely client-side through a *secondary* named [FirebaseApp]
/// instance: creating the driver's Firebase Auth user there leaves the
/// admin's own signed-in session on the default app untouched.
class DriversRepository {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> watchDrivers(String schoolId) {
    return _firestore
        .collection(FirebaseCollections.users)
        .where('role', isEqualTo: 'driver')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((snap) => snap.docs.map(UserModel.fromDoc).toList());
  }

  Future<void> createDriver({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String schoolId,
  }) async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'driverCreation-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final driverUser = credential.user!;
      await driverUser.updateDisplayName(name.trim());

      try {
        await _firestore.collection(FirebaseCollections.users).doc(driverUser.uid).set({
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'role': 'driver',
          'schoolId': schoolId,
          'onboardingComplete': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // The Auth account exists but has no matching Firestore doc — left
        // as-is, that email is permanently stuck ("email-already-in-use" on
        // every retry) with no way to finish setting it up. Delete it so
        // the admin can just try again cleanly.
        await driverUser.delete();
        rethrow;
      }

      await secondaryAuth.signOut();
    } finally {
      await secondaryApp.delete();
    }
  }

  /// Assigning a bus is what unlocks the driver's login. Also stamps the bus
  /// document with the driver so fleet views can resolve driver <-> bus both
  /// ways.
  Future<void> assignBus({required String driverUid, required String? busId}) async {
    final batch = _firestore.batch();
    batch.set(
      _firestore.collection(FirebaseCollections.users).doc(driverUid),
      {'busId': busId},
      SetOptions(merge: true),
    );
    if (busId != null && busId.isNotEmpty) {
      batch.set(
        _firestore.collection(FirebaseCollections.buses).doc(busId),
        {'driverId': driverUid},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
