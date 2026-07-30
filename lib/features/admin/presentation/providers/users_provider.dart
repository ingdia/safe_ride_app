import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../../../shared/providers/auth_state_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/users_repository.dart';
import 'buses_provider.dart';
import 'schools_provider.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(firestoreProvider));
});

// Driver-scoped: users whose IDs appear on buses (for fleet overview)
final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  final buses = ref.watch(busesListProvider);
  final driverIds = buses
      .map((b) => b.driverId)
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList();
  return ref.read(usersRepositoryProvider).getByIds(driverIds);
});

final usersListProvider = Provider<List<UserModel>>((ref) {
  return ref.watch(usersProvider).value ?? [];
});

// School-scoped: all users belonging to this school
final schoolUsersProvider = StreamProvider<List<UserModel>>((ref) async* {
  final school = await ref.watch(schoolProvider.future);
  yield* ref.read(usersRepositoryProvider).streamBySchool(school.schoolId);
});

final schoolUsersListProvider = Provider<List<UserModel>>((ref) {
  return ref.watch(schoolUsersProvider).value ?? [];
});

// Current admin
final currentAdminProvider = FutureProvider<UserModel>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid.isEmpty) throw StateError('No authenticated user');
  final firestore = ref.watch(firestoreProvider);
  final authUser = ref.watch(firebaseAuthProvider).currentUser;

  final doc = await firestore
      .collection(FirebaseCollections.users)
      .doc(uid)
      .get();

  if (doc.exists) return UserModel.fromFirestore(doc);

  return UserModel(
    userId: uid,
    name: authUser?.displayName ?? 'Admin',
    email: authUser?.email ?? '',
    phone: '',
    role: UserRole.admin,
    createdAt: DateTime.now(),
  );
});
