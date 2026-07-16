import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/parent_ui_constants.dart';
import 'parent_home_screen.dart';
import 'parent_notifications_screen.dart';
import 'parent_profile_screen.dart';
import 'parent_tracking_screen.dart';

final _parentSelectedTabProvider =
    NotifierProvider<_ParentSelectedTabController, int>(
      _ParentSelectedTabController.new,
    );

class _ParentSelectedTabController extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void selectTab(int index) {
    state = index;
  }
}

class ParentNavigationShell extends ConsumerWidget {
  const ParentNavigationShell({super.key});

  static const List<Widget> _pages = [
    ParentHomeScreen(),
    ParentTrackingScreen(),
    ParentNotificationsScreen(),
    ParentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(_parentSelectedTabProvider);

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: IndexedStack(index: selectedIndex, children: _pages),
      bottomNavigationBar: _ParentBottomNavigationBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          ref.read(_parentSelectedTabProvider.notifier).selectTab(index);
        },
      ),
    );
  }
}

class _ParentBottomNavigationBar extends StatelessWidget {
  const _ParentBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFFFD65A), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _ParentNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
            ),
            _ParentNavItem(
              icon: Icons.map_outlined,
              activeIcon: Icons.map_rounded,
              label: 'Map',
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
            ),
            _ParentNavItem(
              icon: Icons.notifications_none_rounded,
              activeIcon: Icons.notifications_rounded,
              label: 'Alerts',
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
            ),
            _ParentNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              isSelected: selectedIndex == 3,
              onTap: () => onItemSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentNavItem extends StatelessWidget {
  const _ParentNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = isSelected
        ? ParentUiColors.orange
        : ParentUiColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: ParentUiSpacing.md,
              vertical: ParentUiSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? ParentUiColors.lightOrange
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: itemColor,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: itemColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
