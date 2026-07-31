import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../data/models/school_model.dart';
import '../../data/models/user_model.dart';

class AdminSession {
  const AdminSession({required this.admin, required this.school});
  final UserModel admin;
  final SchoolModel school;
}

/// Resolves the signed-in admin's own user doc and their school doc. This is
/// the one async step the admin shell waits on before rendering anything
/// else — see [AdminNavigationShell], which only builds the rest of the
/// admin UI once this has data.
///
/// `currentAdminProvider` / `adminSchoolIdProvider` / `schoolProvider` below
/// all just re-read this same provider's already-resolved value — they are
/// plain synchronous providers *within the same container*, not overrides
/// on a nested `ProviderScope`. (An earlier version used a nested
/// `ProviderScope` with `overrideWithValue` to fake synchronicity, but that
/// pattern is fragile: Riverpod only guarantees overrides are honored from
/// a `ProviderScope`'s very first build, and rebuilds of the parent widget
/// could silently leave descendants reading the un-overridden — throwing —
/// provider. Reading through `adminSessionProvider` directly sidesteps that
/// entirely, since there's only ever one container.)
final adminSessionProvider = FutureProvider<AdminSession>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) throw StateError('Not authenticated.');

  final firestore = FirebaseFirestore.instance;
  final adminDoc = await firestore.collection(FirebaseCollections.users).doc(uid).get();
  if (!adminDoc.exists) throw StateError('Admin profile not found.');

  final admin = UserModel.fromDoc(adminDoc);
  final schoolId = admin.schoolId;
  if (schoolId == null || schoolId.isEmpty) {
    throw StateError(
      'Your admin account is not linked to a school yet. Contact SafeRide support.',
    );
  }

  final schoolDoc = await firestore.collection(FirebaseCollections.schools).doc(schoolId).get();
  if (!schoolDoc.exists) throw StateError('School "$schoolId" not found.');

  return AdminSession(admin: admin, school: SchoolModel.fromDoc(schoolDoc));
});

/// Only ever watched from inside the admin shell, which gates rendering
/// until [adminSessionProvider] has data — so `orElse` here is unreachable
/// in practice, not a real fallback.
UserModel _requireAdmin(Ref ref) => ref.watch(adminSessionProvider).maybeWhen(
      data: (session) => session.admin,
      orElse: () => throw StateError('Admin session not ready yet.'),
    );

SchoolModel _requireSchool(Ref ref) => ref.watch(adminSessionProvider).maybeWhen(
      data: (session) => session.school,
      orElse: () => throw StateError('Admin session not ready yet.'),
    );

final currentAdminProvider = Provider<UserModel>(_requireAdmin);

final adminSchoolIdProvider = Provider<String>((ref) => _requireSchool(ref).schoolId);
