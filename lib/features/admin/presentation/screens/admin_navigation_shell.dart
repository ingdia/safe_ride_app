import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_navigation_shell.dart';
import '../providers/admin_navigation_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_buses_screen.dart';
import 'admin_users_screen.dart';
import 'admin_settings_screen.dart';

class AdminNavigationShell extends ConsumerWidget {
  const AdminNavigationShell({super.key});

  static const _items = [
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
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  static const _screens = [
    AdminDashboardScreen(),
    AdminBusesScreen(),
    AdminUsersScreen(),
    AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(adminNavigationProvider);

    return AppNavigationShell(
      selectedIndex: selectedIndex,
      onTabSelected: (index) =>
          ref.read(adminNavigationProvider.notifier).selectTab(index),
      items: _items,
      child: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
    );
  }
}
