import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/route_summary_provider.dart';
import '../providers/routes_provider.dart';
import '../providers/schools_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/route_form_sheet.dart';

class ManageRoutesScreen extends ConsumerWidget {
  const ManageRoutesScreen({super.key});

  Future<void> _handleCreate(BuildContext context, WidgetRef ref) async {
    final school = ref.read(schoolProvider);
    final result = await RouteFormSheet.show(
      context,
      schoolId: school.schoolId,
    );
    if (result != null) {
      ref.read(routesProvider.notifier).addRoute(result);
    }
  }

  Future<void> _handleEdit(
    BuildContext context,
    WidgetRef ref,
    String routeId,
  ) async {
    final school = ref.read(schoolProvider);
    final existing = ref
        .read(routesProvider)
        .firstWhere((r) => r.routeId == routeId);
    final result = await RouteFormSheet.show(
      context,
      existingRoute: existing,
      schoolId: school.schoolId,
    );
    if (result != null) {
      ref.read(routesProvider.notifier).updateRoute(result);
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String routeId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(routesProvider.notifier).deleteRoute(routeId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routeSummaryProvider);

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
                  AdminUiSpacing.sm,
                  AdminUiSpacing.md,
                  AdminUiSpacing.lg,
                ),
                child: HeaderTitleBlock(
                  title: 'Manage Routes',
                  subtitle: 'Configure and organize bus routes',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.md,
                AdminUiSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleCreate(context, ref),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create New Route'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverList.separated(
                itemCount: routes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AdminUiSpacing.md),
                itemBuilder: (context, index) => _RouteCard(
                  route: routes[index],
                  onEdit: () =>
                      _handleEdit(context, ref, routes[index].routeId),
                  onDelete: () =>
                      _handleDelete(context, ref, routes[index].routeId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteSummary route;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RouteCard({
    required this.route,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final plate in route.busPlateNumbers)
                          _BusChip(label: 'Bus $plate'),
                      ],
                    ),
                  ],
                ),
              ),
              RoundIconButton(
                icon: Icons.edit_outlined,
                background: AdminUiColors.infoBg,
                foreground: AdminUiColors.infoFg,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              RoundIconButton(
                icon: Icons.delete_outline,
                background: AdminUiColors.delayedBg,
                foreground: AdminUiColors.delayedFg,
                onTap: onDelete,
              ),
            ],
          ),
          const SizedBox(height: AdminUiSpacing.md),
          const Divider(height: 1, color: AdminUiColors.divider),
          const SizedBox(height: AdminUiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.location_on_outlined,
                  label: 'Stops',
                  value: '${route.stopCount}',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.schedule_outlined,
                  label: 'Duration',
                  value: '${route.durationMinutes} min',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.groups_2_outlined,
                  label: 'Students',
                  value: '${route.studentCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminUiSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                backgroundColor: AdminUiColors.statCardBackground,
                side: BorderSide.none,
              ),
              child: const Text('View Route Details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusChip extends StatelessWidget {
  final String label;

  const _BusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AdminUiColors.statCardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.chip),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AdminUiColors.primaryOrangeDark,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AdminUiColors.primaryOrange),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AdminUiColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ],
    );
  }
}
