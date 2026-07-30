import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/route_stop.dart';
import '../providers/driver_route_provider.dart';
import '../providers/driver_route_state.dart';

class DriverRouteScreen extends ConsumerWidget {
  const DriverRouteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeState = ref.watch(driverRouteProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: routeState.when(
          data: (state) {
            if (state is! DriverRouteLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final stops = state.stops;
            final totalStudents = state.students.length;
            final nextStop = stops.firstWhere(
              (stop) => stop.status != RouteStopStatus.completed,
              orElse: () => stops.first,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
              children: [
                Text('Route overview', style: AppTextStyles.headingLarge),
                const SizedBox(height: AppSpacing.xs),
                Text('A clear view of the stops, timing, and pickup flow for the day.', style: AppTextStyles.bodySmall),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text('Bus #12', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Route A', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('$totalStudents students • ${stops.length} stops', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Next stop: ${nextStop.name}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Planned stops', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                ...stops.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _StopTile(stop: entry.value, index: entry.key + 1),
                    )),
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

class _StopTile extends StatelessWidget {
  const _StopTile({required this.stop, required this.index});

  final RouteStop stop;
  final int index;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (stop.status) {
      RouteStopStatus.completed => AppColors.success,
      RouteStopStatus.current => AppColors.primary,
      RouteStopStatus.upcoming => AppColors.textSecondary,
    };
    final statusLabel = switch (stop.status) {
      RouteStopStatus.current => 'Now',
      RouteStopStatus.completed => 'Done',
      RouteStopStatus.upcoming => 'Next',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text('$index', style: AppTextStyles.bodyMedium.copyWith(color: statusColor, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(stop.name, style: AppTextStyles.bodyMedium)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        color: statusColor.withValues(alpha: 0.12),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('${stop.time} • ${stop.studentCount} students', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
