import 'package:flutter/material.dart';

import '../../../features/parent/presentation/widgets/parent_ui_constants.dart';

// ---------------------------------------------------------------------------
// Data model for a single nav item
// ---------------------------------------------------------------------------

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;
}

// ---------------------------------------------------------------------------
// The shell widget — wraps any list of screens with the nav bar
// ---------------------------------------------------------------------------

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.items,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<AppNavItem> items;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: child,
      bottomNavigationBar: _AppBottomNavBar(
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected,
        items: items,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The floating bottom nav bar
// ---------------------------------------------------------------------------

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<AppNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        ParentUiSpacing.md,
        0,
        ParentUiSpacing.md,
        ParentUiSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ParentUiRadius.xl),
        border: Border.all(color: ParentUiColors.border),
        boxShadow: [
          BoxShadow(
            color: ParentUiColors.orange.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ParentUiRadius.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ParentUiSpacing.sm,
            vertical: ParentUiSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavBarItem(
                item: items[index],
                isSelected: selectedIndex == index,
                onTap: () => onTabSelected(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual nav item — animated pill + label expand + badge
// ---------------------------------------------------------------------------

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? ParentUiSpacing.md : ParentUiSpacing.sm,
          vertical: ParentUiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ParentUiColors.lightOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(ParentUiRadius.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? ParentUiColors.orange
                        : ParentUiColors.textGrey,
                    size: 24,
                  ),
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      height: 16,
                      constraints: const BoxConstraints(minWidth: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        color: ParentUiColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          item.badgeCount > 9 ? '9+' : '${item.badgeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Animated label that slides in when selected
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Row(
                      children: [
                        const SizedBox(width: ParentUiSpacing.xs),
                        Text(
                          item.label,
                          style: ParentUiTextStyles.caption.copyWith(
                            color: ParentUiColors.orange,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
