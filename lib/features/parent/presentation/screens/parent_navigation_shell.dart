import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_navigation_shell.dart';
import '../providers/parent_navigation_provider.dart';
import 'parent_home_screen.dart';
import 'parent_notifications_screen.dart';
import 'parent_profile_screen.dart';
import 'parent_tracking_screen.dart';

class ParentNavigationShell extends ConsumerWidget {
  const ParentNavigationShell({super.key});

  static const List<AppNavItem> _items = [
    AppNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
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

  static const List<Widget> _screens = [
    ParentHomeScreen(),
    ParentTrackingScreen(),
    ParentNotificationsScreen(),
    ParentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(parentNavigationProvider).index;

    return AppNavigationShell(
      selectedIndex: selectedIndex,
      onTabSelected: (index) {
        ref.read(parentNavigationProvider.notifier).selectTab(
          parentTabFromIndex(index),
        );
      },
      items: _items,
      child: IndexedStack(index: selectedIndex, children: _screens),
    );
  }
}