import 'package:flutter/material.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

class AdminRoutes {
  const AdminRoutes._();

  static const String dashboard = '/admin/dashboard';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
