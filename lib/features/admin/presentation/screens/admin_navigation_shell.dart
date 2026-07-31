import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_navigation_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_navigation_provider.dart';
import '../providers/admin_session_provider.dart';
import '../widgets/admin_ui_constants.dart';
import 'admin_home_screen.dart';
import 'admin_profile_screen.dart';
import 'manage_drivers_screen.dart';
import 'manage_routes_screen.dart';
import 'pending_students_screen.dart';

// ---------------------------------------------------------------------------
// Admin navigation shell — resolves the admin's own school before rendering
// any admin screen. currentAdminProvider / adminSchoolIdProvider /
// schoolProvider (see admin_session_provider.dart, schools_provider.dart)
// all read straight through adminSessionProvider once it has data, so no
// scope-override wiring is needed here — just gate on it being loaded.
// ---------------------------------------------------------------------------

class AdminNavigationShell extends ConsumerWidget {
  const AdminNavigationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(adminSessionProvider);

    return sessionAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AdminUiColors.scaffoldBackground,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AdminUiColors.scaffoldBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/auth/login', (_) => false);
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (_) => const _AdminShellBody(),
    );
  }
}

class _AdminShellBody extends ConsumerWidget {
  const _AdminShellBody();

  static const List<AppNavItem> _items = <AppNavItem>[
    AppNavItem(
      icon: Icons.directions_bus_outlined,
      activeIcon: Icons.directions_bus_filled_rounded,
      label: 'Buses',
    ),
    AppNavItem(
      icon: Icons.badge_outlined,
      activeIcon: Icons.badge_rounded,
      label: 'Drivers',
    ),
    AppNavItem(
      icon: Icons.how_to_reg_outlined,
      activeIcon: Icons.how_to_reg_rounded,
      label: 'Students',
    ),
    AppNavItem(
      icon: Icons.route_outlined,
      activeIcon: Icons.route_rounded,
      label: 'Routes',
    ),
    AppNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  // IndexedStack preserves state of off-screen children.
  static const List<Widget> _screens = <Widget>[
    FleetOverviewScreen(),
    ManageDriversScreen(),
    PendingStudentsScreen(),
    ManageRoutesScreen(),
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
