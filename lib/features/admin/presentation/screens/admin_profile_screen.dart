import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/users_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(currentAdminProvider);

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                padding: const EdgeInsets.fromLTRB(
                  AdminUiSpacing.md,
                  AdminUiSpacing.lg,
                  AdminUiSpacing.md,
                  AdminUiSpacing.xl + AdminUiSpacing.lg,
                ),
                child: const HeaderTitleBlock(
                  title: 'Profile',
                  subtitle: 'Manage your account',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AdminUiSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -AdminUiSpacing.xl),
                  child: _ProfileCard(
                    name: admin.name,
                    role: 'Fleet Administrator',
                    email: admin.email,
                    phone: admin.phone,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                0,
                AdminUiSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -AdminUiSpacing.lg),
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
                      const _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: 'Manage alert preferences',
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      const _SettingsTile(
                        icon: Icons.shield_outlined,
                        title: 'Privacy & Security',
                        subtitle: 'Update your security settings',
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      const _SettingsTile(
                        icon: Icons.tune_rounded,
                        title: 'App Settings',
                        subtitle: 'Customize your experience',
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      const _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact us',
                      ),
                      const SizedBox(height: AdminUiSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminUiColors.delayedFg,
                            side: const BorderSide(color: AdminUiColors.delayedFg),
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
            ),
          ],
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AdminUiColors.statCardBackground,
                child: Icon(
                  Icons.person_rounded,
                  color: AdminUiColors.primaryOrange,
                  size: 28,
                ),
              ),
              const SizedBox(width: AdminUiSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(
                      color: AdminUiColors.primaryOrange,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AdminUiSpacing.md),
          const Divider(height: 1, color: AdminUiColors.divider),
          const SizedBox(height: AdminUiSpacing.md),
          _ContactRow(icon: Icons.email_outlined, text: email),
          const SizedBox(height: AdminUiSpacing.sm),
          _ContactRow(icon: Icons.phone_outlined, text: phone),
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
        Text(text, style: const TextStyle(fontSize: 13)),
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
            color: AdminUiColors.primaryOrange,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AdminUiRadii.card),
      hoverColor: AdminUiColors.primaryOrange.withValues(alpha: 0.04),
      mouseCursor: SystemMouseCursors.click,
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
                      fontWeight: FontWeight.w600,
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
    );
  }
}
