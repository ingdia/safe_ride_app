import 'package:flutter/material.dart';

import '../../features/parent/presentation/screens/parent_navigation_shell.dart';

class ParentRoutes {
  const ParentRoutes._();

  static const String home = '/parent/home';
  static const String tracking = '/parent/tracking';
  static const String notifications = '/parent/notifications';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const ParentNavigationShell(),
      tracking: (context) => const ParentNavigationShell(),
      notifications: (context) => const ParentNavigationShell(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case tracking:
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const ParentNavigationShell(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
