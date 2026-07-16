import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_navigation_shell.dart';
import '../providers/parent_navigation_provider.dart';
import 'parent_home_screen.dart';
import 'parent_notifications_screen.dart';
import 'parent_tracking_screen.dart';

class ParentNavigationShell extends ConsumerWidget {
  const ParentNavigationShell({super.key});

  static const _items = [
    AppNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppNavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Tracking',
    ),
    AppNavItem(
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_active_rounded,
      label: 'Alerts',
      badgeCount: 2,
    ),
  ];

  static const _screens = [
    ParentHomeScreen(),
    ParentTrackingScreen(),
    ParentNotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(parentNavigationProvider);

    return AppNavigationShell(
      selectedIndex: selectedTab.index,
      onTabSelected: (index) => ref
          .read(parentNavigationProvider.notifier)
          .selectTab(parentTabFromIndex(index)),
      items: _items,
      child: IndexedStack(
        index: selectedTab.index,
        children: _screens,
      ),
    );
  }
}
