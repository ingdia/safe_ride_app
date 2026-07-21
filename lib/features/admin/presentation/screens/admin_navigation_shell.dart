import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_navigation_shell.dart';
import '../providers/admin_navigation_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_buses_screen.dart';
import 'admin_emergency_screen.dart';
import 'admin_users_screen.dart';
import 'admin_settings_screen.dart';

// ---------------------------------------------------------------------------
// Admin navigation shell — wraps admin screens with bottom nav bar
// ---------------------------------------------------------------------------

class AdminNavigationShell extends ConsumerWidget {
  const AdminNavigationShell({super.key});

  static const List<AppNavItem> _items = <AppNavItem>[
    AppNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    AppNavItem(
      icon: Icons.directions_bus_outlined,
      activeIcon: Icons.directions_bus_rounded,
      label: 'Buses',
    ),
    AppNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Users',
    ),
    AppNavItem(
      icon: Icons.emergency_outlined,
      activeIcon: Icons.emergency_rounded,
      label: 'Emergency',
    ),
    AppNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  // IndexedStack preserves state of off-screen children.
  // If memory becomes an issue, consider lazy-loading screens.
  static const List<Widget> _screens = <Widget>[
    AdminDashboardScreen(),
    AdminBusesScreen(),
    AdminUsersScreen(),
    AdminEmergencyScreen(),
    AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(adminNavigationProvider);
    final selectedIndex = selectedTab.index;

    return AppNavigationShell(
      selectedIndex: selectedIndex,
      onTabSelected: (int index) {
        ref.read(adminNavigationProvider.notifier).selectTab(
          adminTabFromIndex(index),
        );
      },
      items: _items,
      child: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
    );
  }
}