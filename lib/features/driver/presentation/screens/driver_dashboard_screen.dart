import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../providers/driver_profile_provider.dart';
import '../providers/driver_route_provider.dart';
import '../providers/driver_route_state.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeState = ref.watch(driverRouteProvider);
    final profile = ref.watch(driverProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: routeState.when(
          data: (state) {
            if (state is! DriverRouteLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final loaded = state;
            final studentCount = loaded.students.length;
            final stopCount = loaded.stops.length;
            final nextStop = loaded.stops.firstWhere(
              (stop) => stop.status != RouteStopStatus.completed,
              orElse: () => loaded.stops.first,
            );
            final boardedCount = loaded.students.where((student) => student.status == AttendanceStatus.boarded).length;
            final remainingCount = studentCount - boardedCount;

            return ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
              children: [
                _HeaderCard(profile: profile),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'Active route',
                  subtitle: '${loaded.stops.length} stops • $studentCount students',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _MetricPill(label: 'Bus', value: '12')),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: _MetricPill(label: 'Boarded', value: '$boardedCount')),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Next stop: ${nextStop.name} • ${nextStop.time}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'Today at a glance',
                  subtitle: 'A clean snapshot of route progress',
                  child: Row(
                    children: [
                      Expanded(child: _MetricPill(label: 'Stops', value: '$stopCount')),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _MetricPill(label: 'Remaining', value: '$remainingCount')),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Quick access', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _ActionChip(label: 'View roster', icon: Icons.groups_outlined),
                    _ActionChip(label: 'Open route', icon: Icons.route_outlined),
                    _ActionChip(label: 'Offline sync', icon: Icons.cloud_off_outlined),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Unable to load route: $error')),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, ${profile.name.split(' ').first}', style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                const SizedBox(height: AppSpacing.xs),
                Text(profile.route, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
