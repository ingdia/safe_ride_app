import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../shared/enums/user_role.dart';
import '../../features/auth/domain/entities/auth_user.dart';
import '../config/super_admin_config.dart';
import 'admin_routes.dart';
import 'auth_routes.dart';
import 'driver_routes.dart';
import 'parent_routes.dart';
import 'super_admin_routes.dart';

class AppRouter {
  const AppRouter._();

  static const String initial = AuthRoutes.login;

  /// Returns the correct dashboard route for the authenticated [user].
  /// Parents who haven't completed onboarding are sent to the onboarding flow.
  static String dashboardForUser(AuthUser user) {
    if (SuperAdminConfig.isSuperAdmin(user.email)) {
      return SuperAdminRoutes.dashboard;
    }
    if (user.role == UserRole.parent && !user.onboardingComplete) {
      return ParentRoutes.onboarding;
    }
    return dashboardForRole(user.role);
  }

  /// Returns the default dashboard route for a [role] (assumes onboarding done).
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
    return AuthRoutes.onGenerateRoute(settings) ??
        ParentRoutes.onGenerateRoute(settings) ??
        DriverRoutes.onGenerateRoute(settings) ??
        AdminRoutes.onGenerateRoute(settings) ??
        SuperAdminRoutes.onGenerateRoute(settings) ??
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
  }
}
