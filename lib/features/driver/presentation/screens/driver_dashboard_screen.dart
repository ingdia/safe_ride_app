import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/trip_entity.dart';
import '../../data/models/driver_alert.dart';
import '../../domain/models/route_stop.dart';
import '../../domain/models/student.dart';
import '../providers/driver_navigation_provider.dart';
import '../providers/driver_profile_provider.dart';
import '../providers/driver_route_provider.dart';
import '../providers/driver_route_state.dart';
import '../widgets/offline_data_banner.dart';

/// The driver's own completed trips — most recent first. Resolves their
/// busId from their own user doc rather than threading it through
/// driverRouteProvider's state, since this is only needed on demand.
final _recentTripsProvider = FutureProvider.autoDispose<List<TripEntity>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const [];

  final firestore = FirebaseFirestore.instance;
  final userDoc = await firestore.collection(FirebaseCollections.users).doc(uid).get();
  final busId = userDoc.data()?['busId'] as String?;
  final schoolId = userDoc.data()?['schoolId'] as String?;
  if (busId == null || busId.isEmpty || schoolId == null || schoolId.isEmpty) return const [];

  // The `trips` rule gates reads on `schoolId`, so it must be an explicit
  // filter here too — filtering by `busId` alone is rejected outright by
  // Firestore, not just empty. Sorted client-side rather than via
  // orderBy() — multiple equality (==) filters alone don't need a
  // composite index in Firestore, but adding orderBy on a different field
  // would, and that index isn't guaranteed to exist/deployed.
  final tripsQuery = await firestore
      .collection(FirebaseCollections.trips)
      .where('schoolId', isEqualTo: schoolId)
      .where('busId', isEqualTo: busId)
      .where('status', isEqualTo: 'completed')
      .limit(30)
      .get();

  final trips = tripsQuery.docs.map(TripEntity.fromDoc).toList()
    ..sort((a, b) => (b.completedAt ?? DateTime(0)).compareTo(a.completedAt ?? DateTime(0)));
  return trips.take(10).toList();
});

/// Tracks the set of alert IDs already shown to the driver this session.
///
/// Persisted only in memory — resets on app restart, which is intentional:
/// alerts shown in a previous session should not re-fire.
class _SeenAlertsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void markSeen(Iterable<String> ids) {
    state = <String>{...state, ...ids};
  }
}

final _seenAlertIdsProvider =
    NotifierProvider<_SeenAlertsNotifier, Set<String>>(
  _SeenAlertsNotifier.new,
);

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();
}

class _DriverDashboardScreenState
    extends ConsumerState<DriverDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(driverRouteProvider);
    final profile = ref.watch(driverProfileProvider).maybeWhen(
          data: (v) => v,
          orElse: () => const DriverProfile(
            name: 'Driver',
            role: 'Driver',
            email: '',
            phone: '',
            busNumber: '—',
            route: 'Loading…',
            license: '',
          ),
        );

    // Resolve routeId from loaded state — empty string when on mock data.
    final routeId = routeState.maybeWhen(
      data: (s) => s is DriverRouteLoaded ? (s.routeId ?? '') : '',
      orElse: () => '',
    );

    // Listen to the alerts stream and show a banner for each new alert.
    // ref.listen in build is the idiomatic Riverpod pattern for side-effects.
    if (routeId.isNotEmpty) {
      ref.listen<AsyncValue<List<DriverAlert>>>(
        driverAlertsStreamProvider(routeId),
        (_, next) {
          final alerts = next.whenOrNull(data: (v) => v);
          if (alerts == null || alerts.isEmpty) return;

          final seen = ref.read(_seenAlertIdsProvider);
          final newAlerts =
              alerts.where((a) => !seen.contains(a.alertId)).toList();
          if (newAlerts.isEmpty) return;

          // Mark all as seen before showing so rapid rebuilds don't re-fire.
          ref
              .read(_seenAlertIdsProvider.notifier)
              .markSeen(newAlerts.map((a) => a.alertId));

          // Show the most recent alert; dismiss any previous banner first.
          final alert = newAlerts.first;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(_alertSnackBar(context, alert));
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: routeState.when(
          data: (state) {
            if (state is! DriverRouteLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final loaded = state;

            if (loaded.stops.isEmpty) {
              return _NoRouteYetState(profile: profile);
            }

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
                if (loaded.isOffline) ...[
                  const OfflineDataBanner(),
                  const SizedBox(height: AppSpacing.sm),
                ],
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
                          Expanded(child: _MetricPill(label: 'Bus', value: profile.busNumber)),
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
                      label: 'Today\'s route',
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

  SnackBar _alertSnackBar(BuildContext context, DriverAlert alert) {
    final isUrgent = alert.type == 'sos';
    return SnackBar(
      duration: Duration(seconds: isUrgent ? 10 : 6),
      backgroundColor:
          isUrgent ? AppColors.error : AppColors.surface,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: isUrgent
              ? AppColors.error
              : AppColors.border,
        ),
      ),
      content: Row(
        children: [
          Icon(
            isUrgent
                ? Icons.warning_amber_rounded
                : Icons.notifications_outlined,
            color: isUrgent ? Colors.white : AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (alert.title.isNotEmpty)
                  Text(
                    alert.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isUrgent ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                Text(
                  alert.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isUrgent
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
                Consumer(
                  builder: (context, ref, _) {
                    final tripsAsync = ref.watch(_recentTripsProvider);
                    return tripsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Unable to load trip history.', style: AppTextStyles.bodyMedium),
                      ),
                      data: (trips) {
                        if (trips.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('No completed trips yet.', style: AppTextStyles.bodyMedium),
                          );
                        }
                        return Column(
                          children: [
                            for (final trip in trips)
                              _HistoryLogTile(
                                title: trip.type == TripType.morning ? 'Morning trip' : 'Afternoon trip',
                                subtitle:
                                    '${_formatDate(trip.completedAt)} • ${trip.studentEvents.length} student events',
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[date.weekday - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$weekday $hour:$minute';
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

class _NoRouteYetState extends StatelessWidget {
  const _NoRouteYetState({required this.profile});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_outlined, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              profile.busNumber == 'Unassigned'
                  ? 'No bus assigned yet'
                  : 'No route set up for ${profile.busNumber} yet',
              style: AppTextStyles.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your school administrator needs to create a route with stops '
              'for your bus before you can start a trip.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
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
