import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/student_entity.dart';
import '../../../../shared/utils/initials.dart';
import '../../data/models/bus_model.dart';
import '../../data/models/route_model.dart';
import '../../data/models/user_model.dart';
import '../providers/buses_provider.dart';
import '../providers/routes_provider.dart';
import '../providers/school_students_provider.dart';
import '../providers/users_provider.dart';
import '../widgets/admin_notification_bell.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

class PendingStudentsScreen extends ConsumerWidget {
  const PendingStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(schoolStudentsProvider);

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: HeaderTitleBlock(
                        title: 'Students',
                        subtitle: 'Review new registrations and assign a bus',
                      ),
                    ),
                    const AdminNotificationBell(),
                  ],
                ),
              ),
            ),
            studentsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Unable to load students.\n$error', textAlign: TextAlign.center),
                ),
              ),
              data: (students) {
                if (students.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No students registered yet.')),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(AdminUiSpacing.md),
                  sliver: SliverList.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AdminUiSpacing.sm),
                    itemBuilder: (context, index) => _StudentCard(student: students[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends ConsumerWidget {
  const _StudentCard({required this.student});
  final StudentEntity student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AdminUiColors.statCardBackground,
                child: Text(
                  initialsFor(student.name),
                  style: const TextStyle(
                    color: AdminUiColors.primaryOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AdminUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('Grade ${student.grade}', style: const TextStyle(color: AdminUiColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              _StatusChip(status: student.status),
            ],
          ),
          if (student.isApproved) ...[
            const SizedBox(height: AdminUiSpacing.sm),
            Text(
              'Bus ${student.busNumber ?? '-'} • ${student.stopName ?? '-'} • ${student.driverName ?? '-'}',
              style: const TextStyle(fontSize: 12.5, color: AdminUiColors.textSecondary),
            ),
          ],
          if (student.isPending) ...[
            if (student.requestedStop != null && student.requestedStop!.trim().isNotEmpty) ...[
              const SizedBox(height: AdminUiSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminUiColors.statCardBackground,
                  borderRadius: BorderRadius.circular(AdminUiRadii.chip),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AdminUiColors.primaryOrange),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Requested pickup: ${student.requestedStop}',
                        style: const TextStyle(fontSize: 12, color: AdminUiColors.primaryOrangeDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AdminUiSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(studentApprovalActionsProvider).reject(student.id),
                    style: OutlinedButton.styleFrom(foregroundColor: AdminUiColors.delayedFg),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AdminUiSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAssignmentSheet(context, ref, student),
                    child: const Text('Approve & Assign'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAssignmentSheet(BuildContext context, WidgetRef ref, StudentEntity student) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignmentSheet(student: student),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final StudentStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case StudentStatus.pending:
        bg = AdminUiColors.statCardBackground;
        fg = AdminUiColors.primaryOrange;
        label = 'Pending';
      case StudentStatus.approved:
        bg = AdminUiColors.onTimeBg;
        fg = AdminUiColors.onTimeFg;
        label = 'Approved';
      case StudentStatus.rejected:
        bg = AdminUiColors.delayedBg;
        fg = AdminUiColors.delayedFg;
        label = 'Rejected';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdminUiRadii.chip)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }
}

class _AssignmentSheet extends ConsumerStatefulWidget {
  const _AssignmentSheet({required this.student});
  final StudentEntity student;

  @override
  ConsumerState<_AssignmentSheet> createState() => _AssignmentSheetState();
}

class _AssignmentSheetState extends ConsumerState<_AssignmentSheet> {
  String? _busId;
  String? _routeId;
  String? _stopName;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final buses = ref.watch(busesProvider);
    final routes = ref.watch(routesProvider);
    final drivers = ref.watch(driversProvider);

    final selectedRoute = routes.where((r) => r.routeId == _routeId).toList();
    final stops = selectedRoute.isNotEmpty ? selectedRoute.first.stops : const <RouteStop>[];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AdminUiSpacing.md,
          AdminUiSpacing.md,
          AdminUiSpacing.md,
          AdminUiSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: AdminUiColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign ${widget.student.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            if (widget.student.requestedStop != null && widget.student.requestedStop!.trim().isNotEmpty) ...[
              const SizedBox(height: AdminUiSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AdminUiSpacing.sm),
                decoration: BoxDecoration(
                  color: AdminUiColors.statCardBackground,
                  borderRadius: BorderRadius.circular(AdminUiRadii.card),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 18, color: AdminUiColors.primaryOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Parent requested pickup near:',
                            style: TextStyle(fontSize: 11.5, color: AdminUiColors.textSecondary),
                          ),
                          Text(
                            widget.student.requestedStop!,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Pick the route/stop below that comes closest to this.',
                  style: TextStyle(fontSize: 11.5, color: AdminUiColors.textSecondary),
                ),
              ),
            ],
            const SizedBox(height: AdminUiSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _busId,
              decoration: const InputDecoration(labelText: 'Bus'),
              items: buses
                  .map((b) => DropdownMenuItem(value: b.busId, child: Text('Bus ${b.plateNumber}')))
                  .toList(),
              onChanged: (v) => setState(() => _busId = v),
            ),
            const SizedBox(height: AdminUiSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _routeId,
              decoration: const InputDecoration(labelText: 'Route'),
              items: routes.map((r) => DropdownMenuItem(value: r.routeId, child: Text(r.name))).toList(),
              onChanged: (v) => setState(() {
                _routeId = v;
                _stopName = null;
              }),
            ),
            const SizedBox(height: AdminUiSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _stopName,
              decoration: const InputDecoration(labelText: 'Stop'),
              items: stops.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
              onChanged: stops.isEmpty ? null : (v) => setState(() => _stopName = v),
            ),
            const SizedBox(height: AdminUiSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_busId == null || _routeId == null || _stopName == null || _submitting)
                    ? null
                    : () => _submit(buses, drivers),
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm Approval'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(List<BusModel> buses, List<UserModel> drivers) async {
    setState(() => _submitting = true);
    final bus = buses.firstWhere((b) => b.busId == _busId);
    final driver = drivers.where((d) => d.userId == bus.driverId).toList();

    await ref.read(studentApprovalActionsProvider).approve(
          studentId: widget.student.id,
          busId: bus.busId,
          busNumber: bus.plateNumber,
          routeId: _routeId!,
          stopName: _stopName!,
          driverName: driver.isNotEmpty ? driver.first.name : 'Unassigned',
          driverPhone: driver.isNotEmpty ? driver.first.phone : '',
        );

    if (mounted) Navigator.of(context).pop();
  }
}
