import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/driver_model.dart';
import '../providers/drivers_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

class PendingDriversScreen extends ConsumerWidget {
  const PendingDriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(driversProvider);
    final pendingCount = drivers
        .where((d) => d.status == DriverApprovalStatus.pending)
        .length;

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: HeaderTitleBlock(
                  title: 'Driver Approvals',
                  subtitle: '$pendingCount awaiting review',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverList.separated(
                itemCount: drivers.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AdminUiSpacing.sm),
                itemBuilder: (context, index) => _DriverCard(
                  driver: drivers[index],
                  onApprove: () => ref
                      .read(driversProvider.notifier)
                      .approveDriver(drivers[index].driverId),
                  onReject: () => ref
                      .read(driversProvider.notifier)
                      .rejectDriver(drivers[index].driverId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _DriverCard({
    required this.driver,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = driver.status == DriverApprovalStatus.pending;

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
              const CircleAvatar(
                radius: 20,
                backgroundColor: AdminUiColors.statCardBackground,
                child: Icon(
                  Icons.person_rounded,
                  color: AdminUiColors.primaryOrange,
                ),
              ),
              const SizedBox(width: AdminUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      driver.email,
                      style: const TextStyle(
                        color: AdminUiColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: driver.status),
            ],
          ),
          const SizedBox(height: AdminUiSpacing.sm),
          Text(
            'License: ${driver.licenseNumber}',
            style: const TextStyle(fontSize: 12.5),
          ),
          Text(
            'Phone: ${driver.phone}',
            style: const TextStyle(fontSize: 12.5),
          ),
          if (isPending) ...[
            const SizedBox(height: AdminUiSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminUiColors.delayedFg,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AdminUiSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DriverApprovalStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case DriverApprovalStatus.pending:
        bg = AdminUiColors.statCardBackground;
        fg = AdminUiColors.primaryOrange;
        label = 'Pending';
        break;
      case DriverApprovalStatus.approved:
        bg = AdminUiColors.onTimeBg;
        fg = AdminUiColors.onTimeFg;
        label = 'Approved';
        break;
      case DriverApprovalStatus.rejected:
        bg = AdminUiColors.delayedBg;
        fg = AdminUiColors.delayedFg;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AdminUiRadii.chip),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
