import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/route_stop.dart';
import '../bloc/driver_route_bloc.dart';
import '../bloc/driver_route_state.dart';
import 'offline_attendance_screen.dart';

/// Driver's "Today's Route" screen.
///
/// Shows the driver a summary of today's route plus the list of stops
/// they'll make, and lets them start the route (kicks off GPS/navigation
/// per the Driver Action user-flow, Fig. 5).
///
/// NOTE: Data is currently static/mocked. This will be wired to
/// `DriverRouteBloc` in Task 2 (feature/driver-bloc) — see the TODOs below.
class TodaysRouteScreen extends StatelessWidget {
  const TodaysRouteScreen({super.key});

  // TODO(Task 2): Replace with real route metadata from the bloc when available.
  static const String _routeName = 'Route A';
  static const String _busNumber = 'Bus #12';

  int _totalStudents(List<RouteStop> stops) =>
      stops.fold(0, (sum, stop) => sum + stop.studentCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<DriverRouteBloc, DriverRouteState>(
          builder: (context, state) {
            if (state is DriverRouteLoading || state is DriverRouteInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DriverRouteError) {
              return Center(
                child: Text(
                  'Unable to load route: ${state.message}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            final loadedState = state as DriverRouteLoaded;
            final stops = loadedState.stops;
            final progress = (loadedState.routeProgress * 100).round();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(
                  child: _buildRouteSummaryCard(
                    context,
                    stops,
                    progress: progress,
                    gpsStatus: loadedState.gpsStatus,
                  ),
                ),
                SliverToBoxAdapter(child: _buildStopsHeader(context, stops)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _RouteStopTile(
                        stop: stops[index],
                        onTap: () => _showStopDetails(context, stops[index]),
                      ),
                      childCount: stops.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl + AppSpacing.xxl),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildStartRouteButton(context),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning!', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Today's Route",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Tappable profile avatar — meets 44x44 min tap target via the
          // InkWell's built-in splash bounds matching the CircleAvatar.
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showProfileMenu(context),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummaryCard(
    BuildContext context,
    List<RouteStop> stops, {
    required int progress,
    required String gpsStatus,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.directions_bus_filled_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _busNumber,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _routeName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _SummaryStat(
                  icon: Icons.location_on_outlined,
                  label: 'Stops',
                  value: '${stops.length}',
                ),
                const SizedBox(width: AppSpacing.lg),
                _SummaryStat(
                  icon: Icons.groups_outlined,
                  label: 'Students',
                  value: '${_totalStudents(stops)}',
                ),
                const SizedBox(width: AppSpacing.lg),
                _SummaryStat(
                  icon: Icons.schedule_outlined,
                  label: 'First Stop',
                  value: stops.first.time,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route status',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$progress% complete • $gpsStatus',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopsHeader(BuildContext context, List<RouteStop> stops) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Route Stops', style: AppTextStyles.headingSmall),
          Text(
            '${stops.length} stops',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartRouteButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: AppSpacing.tapTargetMin + 8, // >= 48dp Material tap target
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO(Task 2): Check GPS status via DriverRouteBloc,
                // then navigate to the Active Route screen (Fig. 5 flow).
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting route…')),
                );
              },
              icon: const Icon(Icons.navigation_rounded),
              label: const Text('Start Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: AppTextStyles.buttonLabel,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.tapTargetMin + 8,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OfflineAttendanceScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.cloud_off_outlined),
              label: const Text('Go to Offline Attendance'),
            ),
          ),
        ],
      ),
    );
  }

  // TODO(Task 2): Replace with real navigation to a stop-detail /
  // student-manifest screen once DriverRouteBloc is wired up.
  void _showStopDetails(BuildContext context, RouteStop stop) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    stop.isDestination
                        ? Icons.flag_rounded
                        : Icons.location_on_rounded,
                    color: stop.isDestination
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(stop.name, style: AppTextStyles.headingSmall),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Scheduled time: ${stop.time}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (!stop.isDestination)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    '${stop.studentCount} student'
                    '${stop.studentCount == 1 ? '' : 's'} to pick up',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  // TODO(Task 2): Wire to real profile/settings/logout actions.
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Log out'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single stop row in the route list.
///
/// Now tappable via InkWell — tapping opens a bottom sheet with stop
/// details. Extracted as a private widget here for now; move to
/// `widgets/route_stop_tile.dart` if it ends up reused elsewhere
/// (e.g. on the Driver Map screen).
class _RouteStopTile extends StatelessWidget {
  const _RouteStopTile({required this.stop, required this.onTap});

  final RouteStop stop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                // Numbered circle — meets 48x48 minimum tap target as part
                // of the tile's overall InkWell tap area.
                Container(
                  width: AppSpacing.tapTargetMin,
                  height: AppSpacing.tapTargetMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: stop.isDestination
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${stop.order}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: stop.isDestination
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stop.name, style: AppTextStyles.bodyMedium),
                      if (!stop.isDestination)
                        Text(
                          '${stop.studentCount} student'
                          '${stop.studentCount == 1 ? '' : 's'}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        Text(
                          'Final destination',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  stop.time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}