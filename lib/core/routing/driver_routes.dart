import 'package:flutter/material.dart';

import '../../features/driver/presentation/screens/driver_dashboard_screen.dart';

class DriverRoutes {
  const DriverRoutes._();

  static const String dashboard = '/driver/dashboard';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DriverDashboardScreen(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
