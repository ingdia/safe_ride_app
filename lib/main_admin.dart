import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/admin/presentation/screens/admin_navigation_shell.dart';
import 'features/admin/presentation/widgets/admin_ui_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Sign in anonymously so currentUidProvider is never empty when using
  // this standalone entry point (bypasses the normal auth flow).
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  runApp(const ProviderScope(child: SafeRideAdminApp()));
}

class SafeRideAdminApp extends StatelessWidget {
  const SafeRideAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRide',
      debugShowCheckedModeBanner: false,
      // AdminTheme.light is applied at the MaterialApp level so every route —
      // including screens pushed via Navigator.push (Reports, Manage Routes,
      // Drivers) — inherits the admin button/color styling. A Theme() wrapper
      // around only `home:` would not cover pushed routes because they are
      // separate Overlay entries, not descendants of home's widget subtree.
      theme: AdminTheme.light,
      home: const AdminNavigationShell(),
    );
  }
}
