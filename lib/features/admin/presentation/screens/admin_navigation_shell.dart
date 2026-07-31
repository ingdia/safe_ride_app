import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_navigation_shell.dart';
import '../providers/admin_navigation_provider.dart';
import 'admin_home_screen.dart';
import 'admin_emergency_screen.dart';
import 'admin_map_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_profile_screen.dart';

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
      icon: Icons.emergency_outlined,
      activeIcon: Icons.emergency_rounded,
      label: 'Emergency',
    ),
    AppNavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Map',
    ),
    AppNavItem(
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_rounded,
      label: 'Alerts',
    ),
    AppNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  // IndexedStack preserves state of off-screen children.
  // If memory becomes an issue, consider lazy-loading screens.
  static const List<Widget> _screens = <Widget>[
    FleetOverviewScreen(),
    AdminEmergencyScreen(),
    LiveMapScreen(),
    NotificationsScreen(),
    ProfileScreen(),
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