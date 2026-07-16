import 'package:flutter/material.dart';

import '../../features/parent/presentation/screens/parent_home_screen.dart';
import '../../features/parent/presentation/screens/parent_notifications_screen.dart';
import '../../features/parent/presentation/screens/parent_tracking_screen.dart';

class ParentRoutes {
  const ParentRoutes._();

  static const String home = '/parent/home';
  static const String tracking = '/parent/tracking';
  static const String notifications = '/parent/notifications';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const ParentHomeScreen(),
      tracking: (context) => const ParentTrackingScreen(),
      notifications: (context) => const ParentNotificationsScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const ParentHomeScreen(),
          settings: settings,
        );

      case tracking:
        return MaterialPageRoute(
          builder: (_) => const ParentTrackingScreen(),
          settings: settings,
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const ParentNotificationsScreen(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
