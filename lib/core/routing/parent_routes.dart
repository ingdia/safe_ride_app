import 'package:flutter/material.dart';

import '../../features/parent/presentation/screens/parent_navigation_shell.dart';

class ParentRoutes {
  const ParentRoutes._();

  static const String home = '/parent/home';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const ParentNavigationShell(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
