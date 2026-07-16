import 'package:flutter/material.dart';

import '../../features/admin/presentation/screens/admin_navigation_shell.dart';

class AdminRoutes {
  const AdminRoutes._();

  static const String dashboard = '/admin/dashboard';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminNavigationShell(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
