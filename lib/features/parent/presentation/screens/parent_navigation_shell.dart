import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/parent_navigation_provider.dart';
import '../widgets/parent_ui_constants.dart';
import 'parent_home_screen.dart';
import 'parent_notifications_screen.dart';
import 'parent_tracking_screen.dart';

class ParentNavigationShell extends ConsumerWidget {
  const ParentNavigationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(parentNavigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedTab.index,
        children: const [
          ParentHomeScreen(),
          ParentTrackingScreen(),
          ParentNotificationsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab.index,
        backgroundColor: Colors.white,
        indicatorColor: ParentUiColors.lightOrange,
        elevation: 4,
        onDestinationSelected: (index) {
          ref
              .read(parentNavigationProvider.notifier)
              .selectTab(parentTabFromIndex(index));
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: ParentUiColors.orange,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded, color: ParentUiColors.orange),
            label: 'Tracking',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(
              Icons.notifications_active_rounded,
              color: ParentUiColors.orange,
            ),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
