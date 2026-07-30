import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_providers.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Returns the UID of the currently signed-in user, or '' when signed out.
final currentUidProvider = Provider<String>((ref) {
  return ref.watch(authStateProvider).value?.uid ?? '';
});
