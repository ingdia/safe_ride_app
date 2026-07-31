import 'package:flutter/material.dart';

import '../../features/super_admin/presentation/screens/super_admin_schools_screen.dart';

class SuperAdminRoutes {
  const SuperAdminRoutes._();

  static const String dashboard = '/super-admin/schools';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const SuperAdminSchoolsScreen(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
