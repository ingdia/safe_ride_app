import 'package:flutter/material.dart';

import '../../features/parent/presentation/screens/parent_navigation_shell.dart';
import '../../features/parent/presentation/screens/parent_onboarding_screen.dart';

class ParentRoutes {
  const ParentRoutes._();

  static const String home = '/parent/home';
  static const String tracking = '/parent/tracking';
  static const String notifications = '/parent/notifications';
  static const String onboarding = '/parent/onboarding';
  static const String pending = '/parent/pending';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case tracking:
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const ParentNavigationShell(),
          settings: settings,
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const ParentOnboardingScreen(),
          settings: settings,
        );

      case pending:
        return MaterialPageRoute(
          builder: (_) => const ParentPendingScreen(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
