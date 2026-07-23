import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../providers/driver_navigation_provider.dart';
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
            final completedStops = loaded.stops.where((stop) => stop.status == RouteStopStatus.completed).length;
            final nextStop = loaded.stops.firstWhere(
              (stop) => stop.status != RouteStopStatus.completed,
              orElse: () => loaded.stops.first,
            );
            final boardedCount = loaded.students.where((student) => student.status == AttendanceStatus.boarded).length;
            final remainingCount = studentCount - boardedCount;
            final todayLabel = _todayLabel();

            return ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
              children: [
                _HeaderCard(
                  profile: profile,
                  routeName: profile.route,
                  todayLabel: todayLabel,
                ),
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
                      Expanded(child: _MetricPill(label: 'Completed', value: '$completedStops')),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _MetricPill(label: 'Remaining', value: '$remainingCount')),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: AppSpacing.tapTargetMin + 8,
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(driverNavigationProvider.notifier).selectTab(1),
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Start Route / Continue Route'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Quick access', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _ActionChip(
                      key: const ValueKey('driver_quick_action_view_roster'),
                      label: 'View roster',
                      icon: Icons.groups_outlined,
                      onTap: () => ref.read(driverNavigationProvider.notifier).selectTab(2),
                    ),
                    _ActionChip(
                      label: 'Today’s route',
                      icon: Icons.route_outlined,
                      onTap: () => ref.read(driverNavigationProvider.notifier).selectTab(1),
                    ),
                    _ActionChip(
                      label: 'Trip history',
                      icon: Icons.history_rounded,
                      onTap: () => _showTripHistory(context),
                    ),
                    _ActionChip(
                      label: 'Profile',
                      icon: Icons.person_outline_rounded,
                      onTap: () => ref.read(driverNavigationProvider.notifier).selectTab(5),
                    ),
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

  void _showTripHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trip history', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                _HistoryLogTile(title: 'North Loop Route', subtitle: 'Mon 07:30 • On time • 4/5 marked'),
                _HistoryLogTile(title: 'Central School Circle', subtitle: 'Fri 07:25 • Delayed 4 min • 3/4 marked'),
                _HistoryLogTile(title: 'New Market Route', subtitle: 'Thu 07:35 • On time • 5/5 marked'),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _todayLabel() {
  final now = DateTime.now();
  const weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.profile,
    required this.routeName,
    required this.todayLabel,
  });

  final DriverProfile profile;
  final String routeName;
  final String todayLabel;

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
                Text(
                  'Good morning, ${profile.name.split(' ').first}',
                  style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  todayLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  routeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
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
  const _ActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
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
        ),
      ),
    );
  }
}

class _HistoryLogTile extends StatelessWidget {
  const _HistoryLogTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
