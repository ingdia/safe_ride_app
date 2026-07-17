import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OfflineAttendanceScreen extends StatelessWidget {
  const OfflineAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offline Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Offline mode placeholder', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This screen will allow the driver to mark students and save attendance locally when no network is available.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Offline attendance scaffolding', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: AppSpacing.sm),
                    Text('• Save attendance locally using Hive when offline.'),
                    SizedBox(height: AppSpacing.xs),
                    Text('• Detect network availability with connectivity_plus.'),
                    SizedBox(height: AppSpacing.xs),
                    Text('• Sync cached attendance when connectivity returns.'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Return to driver route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
