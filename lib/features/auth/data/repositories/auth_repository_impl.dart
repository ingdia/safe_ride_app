import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/config/super_admin_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/enums/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Unable to sign in.');
      }

      try {
        return await _buildAuthUser(firebaseUser);
      } on AuthException {
        await _auth.signOut();
        rethrow;
      }
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    } catch (error) {
      throw AuthException(error.toString());
    }
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await _auth.signInWithCredential(credential);
      final firebaseUser = authResult.user;
      if (firebaseUser == null) {
        throw const AuthException('Unable to sign in with Google.');
      }

      final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          'name': firebaseUser.displayName ?? 'Google User',
          'email': firebaseUser.email ?? '',
          'role': UserRole.parent.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Google accounts are inherently email-verified by Google, so skip
      // the app's own email-verification gate.
      return await _buildAuthUser(firebaseUser, isGoogleSignIn: true);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    } catch (error) {
      throw AuthException(error.toString());
    }
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Unable to create account.');
      }

      await firebaseUser.updateDisplayName(name.trim());
      await firebaseUser.reload();
      await firebaseUser.sendEmailVerification();

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': UserRole.parent.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthUser(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: UserRole.parent,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    } catch (error) {
      // The Firebase Auth account may already exist even though this failed
      // (e.g. the Firestore user-doc write was rejected by security rules
      // after account creation succeeded) — surface it instead of hanging.
      throw AuthException(
        'Account setup failed: $error\n\n'
        'If you retry with the same email, use "Forgot password" instead — '
        'the account may have already been created.',
      );
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    } catch (error) {
      throw AuthException(error.toString());
    }
  }

  @override
  Future<void> signOut() async {
    // Google sign-out is best-effort cleanup — most accounts (including the
    // super admin) never signed in via Google at all, and on some platforms
    // calling signOut() without an active Google session throws. That must
    // never block the actual Firebase Auth sign-out below, which is the
    // part that determines whether the app treats you as logged in.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await _auth.signOut();
  }

  @override
  Future<AuthUser?> currentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    try {
      return await _buildAuthUser(firebaseUser);
    } on AuthException {
      await _auth.signOut();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser> _buildAuthUser(User firebaseUser, {bool isGoogleSignIn = false}) async {
    // The super admin is identified purely by email (see SuperAdminConfig) —
    // no Firestore role/schoolId doc is required, and none of the
    // parent/driver gates below apply to them.
    if (SuperAdminConfig.isSuperAdmin(firebaseUser.email)) {
      return AuthUser(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Super Admin',
        email: firebaseUser.email!,
        role: UserRole.admin,
        onboardingComplete: true,
      );
    }

    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    final data = userDoc.data() ?? <String, dynamic>{};

    final roleName = (data['role'] as String?) ?? UserRole.parent.name;
    final role = UserRole.values.firstWhere(
      (value) => value.name == roleName,
      orElse: () => UserRole.parent,
    );

    // Only parents self-register, so only parents need the anti-abuse email
    // verification step. Driver/admin accounts are created directly by an
    // administrator and have no self-service verification path.
    // Google sign-in users are already verified by Google, so skip the check.
    if (role == UserRole.parent && !isGoogleSignIn && !firebaseUser.emailVerified) {
      throw const AuthException(
        'Please verify your email before signing in.',
      );
    }

    if (role == UserRole.driver) {
      final busId = data['busId'] as String?;
      if (busId == null || busId.isEmpty) {
        throw const AuthException(
          'Your account has not been assigned to a bus yet. '
          'Please contact your school administrator.',
        );
      }
    }

    final displayName = (data['name'] as String?) ?? firebaseUser.displayName ?? '';
    final email = firebaseUser.email ?? '';
    final onboardingComplete = (data['onboardingComplete'] as bool?) ?? false;

    return AuthUser(
      id: firebaseUser.uid,
      name: displayName,
      email: email,
      role: role,
      onboardingComplete: onboardingComplete,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      // Modern Firebase Auth returns this generic code for both a wrong
      // email/password combo AND some Google credential failures — it
      // deliberately doesn't distinguish "no such account" from "wrong
      // password" (anti-enumeration). The message has to stay generic
      // enough to cover both cases correctly.
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);
