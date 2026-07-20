import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_navigation_provider.dart';
import 'admin_ui_constants.dart';

class AdminNavigationShell extends ConsumerWidget {
  final Widget homeChild;
  final Widget mapChild;
  final Widget alertsChild;
  final Widget profileChild;

  const AdminNavigationShell({
    super.key,
    required this.homeChild,
    required this.mapChild,
    required this.alertsChild,
    required this.profileChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(adminNavigationProvider);

    final children = <AdminTab, Widget>{
      AdminTab.home: homeChild,
      AdminTab.map: mapChild,
      AdminTab.alerts: alertsChild,
      AdminTab.profile: profileChild,
    };

    return Scaffold(
      body: IndexedStack(
        index: currentTab.index,
        children: AdminTab.values.map((t) => children[t]!).toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AdminUiColors.cardBackground,
            border: Border(top: BorderSide(color: AdminUiColors.divider)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AdminTab.values.map((tab) {
              final selected = tab == currentTab;
              return _NavBarItem(
                tab: tab,
                selected: selected,
                onTap: () =>
                    ref.read(adminNavigationProvider.notifier).selectTab(tab),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final AdminTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon {
    switch (tab) {
      case AdminTab.home:
        return Icons.home_rounded;
      case AdminTab.map:
        return Icons.map_outlined;
      case AdminTab.alerts:
        return Icons.notifications_none_rounded;
      case AdminTab.profile:
        return Icons.person_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AdminUiColors.primaryOrange
        : AdminUiColors.textSecondary;

    return InkWell(
      onTap: onTap,
      hoverColor: AdminUiColors.primaryOrange.withValues(alpha: 0.06),
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(AdminUiRadii.chip),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: AdminUiSpacing.sm,
          horizontal: selected ? AdminUiSpacing.md : AdminUiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AdminUiColors.statCardBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AdminUiRadii.chip),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
