import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bus_model.dart';
import '../providers/buses_provider.dart';
import '../providers/drivers_provider.dart';
import '../providers/fleet_overview_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/schools_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/fleet_bus_card.dart';
import '../widgets/notification_tile.dart';
import '../widgets/bus_form_sheet.dart';
import 'manage_routes_screen.dart';
import 'pending_drivers_screen.dart';
import 'reports_analytics_screen.dart';

class FleetOverviewScreen extends ConsumerWidget {
  const FleetOverviewScreen({super.key});

  Future<void> _handleAddBus(BuildContext context, WidgetRef ref) async {
    final school = ref.read(schoolProvider);
    final result = await BusFormSheet.show(context, schoolId: school.schoolId);
    if (result != null) {
      ref.read(busesProvider.notifier).addBus(result);
    }
  }

  Future<void> _handleEditBus(
    BuildContext context,
    WidgetRef ref,
    String busId,
  ) async {
    final school = ref.read(schoolProvider);
    final buses = ref.read(busesProvider);
    BusModel? existing;
    for (final bus in buses) {
      if (bus.busId == busId) {
        existing = bus;
        break;
      }
    }
    if (existing == null) {
      // Bus was removed (e.g. deleted from another session/tab) between
      // the card rendering and this tap registering. Bail out quietly
      // instead of crashing with "Bad state: No element".
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This bus no longer exists')),
        );
      }
      return;
    }
    final result = await BusFormSheet.show(
      context,
      existingBus: existing,
      schoolId: school.schoolId,
    );
    if (result != null) {
      ref.read(busesProvider.notifier).updateBus(result);
    }
  }

  Future<void> _handleDeleteBus(
    BuildContext context,
    WidgetRef ref,
    String busId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bus'),
        content: const Text(
          'Are you sure you want to remove this bus from the fleet?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(busesProvider.notifier).deleteBus(busId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(fleetSummaryProvider);
    final stats = ref.watch(fleetStatsProvider);
    final notifications = ref.watch(notificationsProvider).take(3).toList();
    final pendingDriverCount = ref.watch(pendingDriversCountProvider);

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
                      title: 'Fleet Overview',
                      subtitle: 'Real-time monitoring and management',
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
                          icon: Icons.groups_2_rounded,
                          value: '${stats.totalStudents}',
                          label: 'Students',
                        ),
                        StatCard(
                          icon: Icons.trending_up_rounded,
                          value: '${stats.onTimePercent}%',
                          label: 'On Time',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.lg,
                AdminUiSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Active Fleet',
                  trailing: '${summaries.length} buses',
                  onAdd: () => _handleAddBus(context, ref),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminUiSpacing.md,
              ),
              sliver: SliverList.separated(
                itemCount: summaries.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AdminUiSpacing.sm),
                itemBuilder: (context, index) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: FleetBusCard(
                      summary: summaries[index],
                      onEdit: () =>
                          _handleEditBus(context, ref, summaries[index].busId),
                      onDelete: () => _handleDeleteBus(
                        context,
                        ref,
                        summaries[index].busId,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.lg,
                AdminUiSpacing.md,
                0,
              ),
              sliver: const SliverToBoxAdapter(
                child: _SectionHeader(title: 'Recent Alerts'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminUiSpacing.md,
              ),
              sliver: SliverList.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AdminUiSpacing.sm),
                itemBuilder: (context, index) =>
                    AlertPreviewTile(notification: notifications[index]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ManageRoutesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined, size: 18),
                        label: const Text('Routes'),
                      ),
                    ),
                    const SizedBox(width: AdminUiSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PendingDriversScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.badge_outlined, size: 18),
                        label: Text('Drivers ($pendingDriverCount)'),
                      ),
                    ),
                    const SizedBox(width: AdminUiSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportsAnalyticsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bar_chart_rounded, size: 18),
                        label: const Text('Reports'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AdminUiSpacing.lg),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onAdd;

  const _SectionHeader({required this.title, this.trailing, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminUiSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Row(
            children: [
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    color: AdminUiColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              if (onAdd != null) ...[
                const SizedBox(width: AdminUiSpacing.sm),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(8),
                  mouseCursor: SystemMouseCursors.click,
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.add_circle_rounded,
                      color: AdminUiColors.primaryOrange,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
