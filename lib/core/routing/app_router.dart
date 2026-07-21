import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../shared/enums/user_role.dart';
import 'admin_routes.dart';
import 'auth_routes.dart';
import 'driver_routes.dart';
import 'parent_routes.dart';

class AppRouter {
  const AppRouter._();

  static const String initial = AuthRoutes.login;

  /// Returns the correct dashboard route for the authenticated [role].
  static String dashboardForRole(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return ParentRoutes.home;
      case UserRole.driver:
        return DriverRoutes.dashboard;
      case UserRole.admin:
        return AdminRoutes.shell;
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Delegate to feature routers in order
    return AuthRoutes.onGenerateRoute(settings) ??
        ParentRoutes.onGenerateRoute(settings) ??
        DriverRoutes.onGenerateRoute(settings) ??
        AdminRoutes.onGenerateRoute(settings) ??
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
  }
}
