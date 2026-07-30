import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/drivers_provider.dart';
import '../providers/fleet_overview_provider.dart';
import '../providers/notifications_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';
import '../widgets/stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(fleetStatsProvider);
    final pendingDrivers = ref.watch(pendingDriversCountProvider);
    final unreadAlerts = ref.watch(unreadNotificationsCountProvider);
    final sosBuses = ref.watch(fleetSummaryProvider)
        .where((s) => s.status == FleetBusStatus.sos)
        .length;

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeaderTitleBlock(
                      title: 'Admin Dashboard',
                      subtitle: 'Fleet activity, alerts, and operational health',
                    ),
                    const SizedBox(height: AdminUiSpacing.lg),
                    StatRow(
                      cards: [
                        StatCard(
                          icon: Icons.directions_bus_filled_rounded,
                          value: '${stats.activeBuses}',
                          label: 'Active Buses',
                        ),
                        StatCard(
                          icon: Icons.trending_up_rounded,
                          value: '${stats.onTimePercent}%',
                          label: 'On Time',
                        ),
                        StatCard(
                          icon: Icons.groups_2_rounded,
                          value: '${stats.totalStudents}',
                          label: 'Students',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverList.separated(
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AdminUiSpacing.md),
                itemCount: 3,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _SummaryCard(
                      icon: Icons.badge_outlined,
                      iconColor: AdminUiColors.primaryOrange,
                      title: 'Pending Drivers',
                      value: '$pendingDrivers',
                      detail: pendingDrivers == 0
                          ? 'No pending approvals'
                          : '$pendingDrivers awaiting approval',
                    );
                  }
                  if (index == 1) {
                    return _SummaryCard(
                      icon: Icons.notifications_outlined,
                      iconColor: unreadAlerts > 0
                          ? AdminUiColors.delayedFg
                          : AdminUiColors.onTimeFg,
                      title: 'Open Alerts',
                      value: '$unreadAlerts',
                      detail: unreadAlerts == 0
                          ? 'All clear'
                          : '$unreadAlerts unread notification${unreadAlerts == 1 ? '' : 's'}',
                    );
                  }
                  return _SummaryCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: sosBuses > 0
                        ? AdminUiColors.dangerFg
                        : AdminUiColors.onTimeFg,
                    title: 'SOS Alerts',
                    value: '$sosBuses',
                    detail: sosBuses == 0
                        ? 'No active emergencies'
                        : '$sosBuses bus${sosBuses == 1 ? '' : 'es'} need attention',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AdminUiColors.statCardBackground,
              borderRadius: BorderRadius.circular(AdminUiRadii.card),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AdminUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AdminUiColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
