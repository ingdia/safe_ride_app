import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_navigation_shell.dart';
import '../providers/driver_navigation_provider.dart';
import 'driver_dashboard_screen.dart';
import 'driver_route_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_sos_screen.dart';

class DriverNavigationShell extends ConsumerWidget {
  const DriverNavigationShell({super.key});

  static const _items = [
    AppNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    AppNavItem(
      icon: Icons.route_outlined,
      activeIcon: Icons.route_rounded,
      label: 'My Route',
    ),
    AppNavItem(
      icon: Icons.emergency_outlined,
      activeIcon: Icons.emergency_rounded,
      label: 'SOS',
      badgeCount: 0,
    ),
    AppNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const _screens = [
    DriverDashboardScreen(),
    DriverRouteScreen(),
    DriverSosScreen(),
    DriverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(driverNavigationProvider);

    return AppNavigationShell(
      selectedIndex: selectedIndex,
      onTabSelected: (index) =>
          ref.read(driverNavigationProvider.notifier).selectTab(index),
      items: _items,
      child: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
    );
  }
}
