import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/users_provider.dart';
import '../widgets/admin_ui_constants.dart';
import 'app_settings_screen.dart';
import 'help_support_screen.dart';
import 'notification_preferences_screen.dart';

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$feature is coming soon')));
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminAsync = ref.watch(currentAdminProvider);
    final admin = adminAsync.value;

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: adminAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (_) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GradientHeader(
                  padding: const EdgeInsets.fromLTRB(
                    AdminUiSpacing.md,
                    AdminUiSpacing.lg,
                    AdminUiSpacing.md,
                    AdminUiSpacing.xl,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const HeaderTitleBlock(
                        title: 'Profile',
                        subtitle: 'Manage your account',
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 70,
                        child: _ProfileCard(
                          name: admin?.name ?? '',
                          role: 'Fleet Administrator',
                          email: admin?.email ?? '',
                          phone: admin?.phone ?? '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 200)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AdminUiSpacing.md,
                  0,
                  AdminUiSpacing.md,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: 'Manage alert preferences',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationPreferencesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      _SettingsTile(
                        icon: Icons.shield_outlined,
                        title: 'Privacy & Security',
                        subtitle: 'Update your security settings',
                        onTap: () =>
                            _showComingSoon(context, 'Privacy & Security'),
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      _SettingsTile(
                        icon: Icons.tune_rounded,
                        title: 'App Settings',
                        subtitle: 'Customize your experience',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AppSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact us',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AdminUiSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showComingSoon(context, 'Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminUiColors.dangerFg,
                            side: const BorderSide(
                              color: AdminUiColors.dangerFg,
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Logout & Switch Role'),
                        ),
                      ),
                      const SizedBox(height: AdminUiSpacing.lg),
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              'SafeRide v1.0.0',
                              style: TextStyle(
                                color: AdminUiColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '© 2026 SafeRide Transportation',
                              style: TextStyle(
                                color: AdminUiColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AdminUiSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AdminUiSpacing.md,
        AdminUiSpacing.lg,
        AdminUiSpacing.md,
        AdminUiSpacing.md,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminUiColors.primaryOrange,
            AdminUiColors.primaryOrangeDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminUiSpacing.sm,
              vertical: AdminUiSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AdminUiRadii.card),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_rounded, size: 16, color: Colors.white),
                SizedBox(width: AdminUiSpacing.xs),
                Text(
                  'Admin account',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminUiSpacing.sm),
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AdminUiSpacing.xs),
          Text(
            'Manage your fleet administration account',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String email;
  final String phone;

  const _ProfileCard({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.lg),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.primaryOrange, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AdminUiColors.primaryOrange,
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: AdminUiColors.statCardBackground,
                  child: Icon(
                    Icons.person_rounded,
                    color: AdminUiColors.primaryOrange,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: AdminUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AdminUiColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AdminUiSpacing.xs),
                    Text(
                      role,
                      style: const TextStyle(
                        color: AdminUiColors.primaryOrangeDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminUiSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminUiSpacing.sm,
              vertical: AdminUiSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AdminUiColors.primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AdminUiRadii.chip),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.route_rounded,
                  size: 18,
                  color: AdminUiColors.primaryOrangeDark,
                ),
                const SizedBox(width: AdminUiSpacing.xs),
                Expanded(
                  child: Text(
                    'Operations ready • SafeRide fleet coordination',
                    style: const TextStyle(
                      color: AdminUiColors.primaryOrangeDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminUiSpacing.md),
          const Divider(height: 1, color: AdminUiColors.divider),
          const SizedBox(height: AdminUiSpacing.md),
          _ContactRow(icon: Icons.mail_outline_rounded, text: email),
          const SizedBox(height: AdminUiSpacing.sm),
          _ContactRow(icon: Icons.call_outlined, text: phone),
          const SizedBox(height: AdminUiSpacing.sm),
          _ContactRow(
            icon: Icons.location_on_outlined,
            text: 'Kigali Operations Center',
          ),
          const SizedBox(height: AdminUiSpacing.md),
          const Divider(height: 1, color: AdminUiColors.divider),
          const SizedBox(height: AdminUiSpacing.md),
          const Row(
            children: [
              Expanded(
                child: _LabeledValue(
                  label: 'Department',
                  value: 'Transportation Services',
                ),
              ),
              Expanded(
                child: _LabeledValue(
                  label: 'Employee ID',
                  value: 'ADM-2024-105',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AdminUiColors.primaryOrange),
        const SizedBox(width: AdminUiSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AdminUiColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AdminUiColors.textSecondary,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AdminUiColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        child: Container(
          padding: const EdgeInsets.all(AdminUiSpacing.md),
          decoration: BoxDecoration(
            color: AdminUiColors.cardBackground,
            borderRadius: BorderRadius.circular(AdminUiRadii.card),
            border: Border.all(color: AdminUiColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AdminUiColors.statCardBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AdminUiColors.primaryOrange, size: 18),
              ),
              const SizedBox(width: AdminUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AdminUiColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AdminUiColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
