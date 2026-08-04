import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../shared/providers/auth_state_provider.dart';
import '../../domain/entities/auth_user.dart';
import '../../data/repositories/auth_repository_impl.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthRegistrationPendingVerification extends AuthState {
  const AuthRegistrationPendingVerification();
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      await PreferencesService.instance.setLoggedIn(true);
      await PreferencesService.instance.saveLastSignedInEmail(user.email);
      await NotificationService.instance.showWelcomeNotification(
        title: 'Welcome back, ${user.name.split(' ').first}',
        body: 'You are signed in and ready to track your child safely.',
      );
      state = AuthAuthenticated(user);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.loginWithGoogle();
      await PreferencesService.instance.setLoggedIn(true);
      await PreferencesService.instance.saveLastSignedInEmail(user.email);
      await NotificationService.instance.showWelcomeNotification(
        title: 'Welcome, ${user.name.split(' ').first}',
        body: 'Google sign-in was successful. Ready to continue.',
      );
      state = AuthAuthenticated(user);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(
        name: name,
        email: email,
        password: password,
      );
      state = const AuthRegistrationPendingVerification();
    } on AuthException catch (e) {
      state = AuthError(e.message);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    state = const AuthLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.forgotPassword(email: email);
      state = const AuthPasswordResetSent();
    } on AuthException catch (e) {
      state = AuthError(e.message);
    }
  }

  Future<void> signOut() async {
    // Always land back at AuthInitial, even if the repository call throws —
    // an unhandled exception here previously meant the caller's button
    // handler never reached its post-sign-out navigation, so the screen
    // just... stayed put with no error shown.
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
      // Swallow — callers navigate to the login screen unconditionally
      // right after calling this, and authUserProvider (driven by Firebase's
      // own authStateChanges stream) is the real source of truth for
      // whether a session is still active, not this notifier's state.
    }
    state = const AuthInitial();
  }

  void clearError() {
    if (state is AuthError) state = const AuthInitial();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Rebuilds whenever Firebase's own auth state changes (sign-in, sign-out,
/// token invalidation) — not just on the initial app launch — so a sign-out
/// triggered from anywhere in the app is reflected immediately everywhere
/// this provider is watched.
final authUserProvider = FutureProvider<AuthUser?>((ref) async {
  ref.watch(authStateProvider);
  final repo = ref.read(authRepositoryProvider);
  return repo.currentUser();
});
