import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/driver_profile_provider.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(driverProfileProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
          children: [
            Text('Profile', style: AppTextStyles.headingLarge),
            const SizedBox(height: AppSpacing.xs),
            Text('Driver details and account settings', style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: const Icon(Icons.person, size: 34, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(profile.name, style: AppTextStyles.headingSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(profile.role, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(label: 'Email', value: profile.email),
                  _InfoRow(label: 'Phone', value: profile.phone),
                  _InfoRow(label: 'Bus Number', value: profile.busNumber),
                  _InfoRow(label: 'Route', value: profile.route),
                  _InfoRow(label: 'License', value: profile.license),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Settings', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            _SettingsTile(title: 'Notifications', subtitle: 'Route reminders and alerts', icon: Icons.notifications_outlined),
            _SettingsTile(title: 'Privacy & Security', subtitle: 'Manage account visibility', icon: Icons.lock_outline_rounded),
            _SettingsTile(title: 'App Settings', subtitle: 'Theme, sound, and preferences', icon: Icons.tune_rounded),
            _SettingsTile(title: 'Help & Support', subtitle: 'Contact the SafeRide team', icon: Icons.support_agent_rounded),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: AppSpacing.tapTargetMin + 8,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout & Switch Role'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(width: 105, child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}
