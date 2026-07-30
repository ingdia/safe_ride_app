import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../../../shared/providers/auth_state_provider.dart';
import '../../data/models/school_model.dart';

/// Fetches the school managed by the currently signed-in admin.
/// Queries `schools` where `admin_id == currentUser.uid`.
///
/// Yields:
///   - AsyncLoading while the query is in flight
///   - AsyncData(SchoolModel) on success
///   - AsyncError with a human-readable message on failure
final schoolProvider = FutureProvider<SchoolModel>((ref) async {
  final uid = ref.watch(currentUidProvider);
  final firestore = ref.watch(firestoreProvider);

  try {
    final snap = await firestore
        .collection(FirebaseCollections.schools)
        .where('admin_id', isEqualTo: uid)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      throw Exception('No school found for this admin account.');
    }

    final doc = snap.docs.first;
    final data = doc.data();
    return SchoolModel(
      schoolId: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      adminId: data['admin_id'] as String? ?? '',
    );
  } on FirebaseException catch (e) {
    throw Exception('Could not load school: ${e.message}');
  }
});
