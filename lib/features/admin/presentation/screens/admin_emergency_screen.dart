import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';
import '../../../driver/domain/entities/emergency_alert.dart';
import '../../../driver/presentation/providers/alerts_provider.dart';

class AdminEmergencyScreen extends ConsumerStatefulWidget {
  const AdminEmergencyScreen({super.key});

  @override
  ConsumerState<AdminEmergencyScreen> createState() =>
      _AdminEmergencyScreenState();
}

class _AdminEmergencyScreenState extends ConsumerState<AdminEmergencyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entranceFade =
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alertsProvider.notifier).loadAlerts();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AlertsState>(alertsProvider, (_, next) {
      if (next is AlertsLoaded) _entranceController.forward(from: 0);
      if (next is AlertsError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: ParentUiColors.danger,
          ),
        );
      }
    });

    final state = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = constraints.maxWidth > 600
                ? ParentUiSpacing.xl
                : ParentUiSpacing.md;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      hPad, ParentUiSpacing.md, hPad, ParentUiSpacing.md),
                  child: const _EmergencyHeader(isAdmin: true),
                ),
                Expanded(
                  child: switch (state) {
                    AlertsInitial() || AlertsLoading() => const Center(
                        child: CircularProgressIndicator(
                          color: ParentUiColors.orange,
                          strokeWidth: 2.5,
                        ),
                      ),
                    AlertsError(:final message) => _ErrorView(
                        message: message,
                        onRetry: () =>
                            ref.read(alertsProvider.notifier).loadAlerts(),
                      ),
                    AlertsLoaded(:final alerts) => FadeTransition(
                        opacity: _entranceFade,
                        child: SlideTransition(
                          position: _entranceSlide,
                          child: _AlertList(
                            alerts: alerts,
                            hPad: hPad,
                            isAdmin: true,
                            onAcknowledge: (id) => ref
                                .read(alertsProvider.notifier)
                                .acknowledgeAlert(id),
                            onResolve: (id) => ref
                                .read(alertsProvider.notifier)
                                .resolveAlert(id),
                          ),
                        ),
                      ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _EmergencyHeader extends StatelessWidget {
  const _EmergencyHeader({required this.isAdmin});
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: ParentUiColors.danger.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(ParentUiRadius.md),
            border: Border.all(
                color: ParentUiColors.danger.withValues(alpha: 0.25)),
          ),
          child: const Icon(Icons.emergency_rounded,
              color: ParentUiColors.danger, size: 28),
        ),
        const SizedBox(width: ParentUiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Emergency Alerts', style: ParentUiTextStyles.title),
              const SizedBox(height: 2),
              Text(
                isAdmin
                    ? 'Acknowledge and resolve active alerts'
                    : 'Live safety alerts for your child\'s bus',
                style: ParentUiTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Alert list
// ---------------------------------------------------------------------------

class _AlertList extends StatelessWidget {
  const _AlertList({
    required this.alerts,
    required this.hPad,
    required this.isAdmin,
    this.onAcknowledge,
    this.onResolve,
  });

  final List<EmergencyAlert> alerts;
  final double hPad;
  final bool isAdmin;
  final void Function(String id)? onAcknowledge;
  final void Function(String id)? onResolve;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const _EmptyView();
    }

    final active = alerts.where((a) => a.status == EmergencyStatus.active).toList();
    final others = alerts.where((a) => a.status != EmergencyStatus.active).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, ParentUiSpacing.xl),
      children: [
        if (active.isNotEmpty) ...[
          _SummaryRow(alerts: alerts),
          const SizedBox(height: ParentUiSpacing.lg),
          Text('Active', style: ParentUiTextStyles.heading),
          const SizedBox(height: ParentUiSpacing.sm),
          ...active.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: ParentUiSpacing.sm),
                child: _AlertCard(
                  alert: a,
                  isAdmin: isAdmin,
                  onAcknowledge: onAcknowledge,
                  onResolve: onResolve,
                ),
              )),
          if (others.isNotEmpty) ...[
            const SizedBox(height: ParentUiSpacing.md),
            Text('Earlier', style: ParentUiTextStyles.heading),
            const SizedBox(height: ParentUiSpacing.sm),
          ],
        ] else ...[
          _SummaryRow(alerts: alerts),
          const SizedBox(height: ParentUiSpacing.lg),
          Text('All Alerts', style: ParentUiTextStyles.heading),
          const SizedBox(height: ParentUiSpacing.sm),
        ],
        ...others.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: ParentUiSpacing.sm),
              child: _AlertCard(
                alert: a,
                isAdmin: isAdmin,
                onAcknowledge: onAcknowledge,
                onResolve: onResolve,
              ),
            )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.alerts});
  final List<EmergencyAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final active =
        alerts.where((a) => a.status == EmergencyStatus.active).length;
    final acknowledged =
        alerts.where((a) => a.status == EmergencyStatus.acknowledged).length;
    final resolved =
        alerts.where((a) => a.status == EmergencyStatus.resolved).length;

    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            label: 'Active',
            count: active,
            color: ParentUiColors.danger,
          ),
        ),
        const SizedBox(width: ParentUiSpacing.sm),
        Expanded(
          child: _SummaryChip(
            label: 'In progress',
            count: acknowledged,
            color: ParentUiColors.warning,
          ),
        ),
        const SizedBox(width: ParentUiSpacing.sm),
        Expanded(
          child: _SummaryChip(
            label: 'Resolved',
            count: resolved,
            color: ParentUiColors.success,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ParentUiSpacing.sm,
        vertical: ParentUiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ParentUiRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: ParentUiTextStyles.heading.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: ParentUiTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Alert card
// ---------------------------------------------------------------------------

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.isAdmin,
    this.onAcknowledge,
    this.onResolve,
  });

  final EmergencyAlert alert;
  final bool isAdmin;
  final void Function(String id)? onAcknowledge;
  final void Function(String id)? onResolve;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(alert.status);
    final isActive = alert.status == EmergencyStatus.active;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ParentUiRadius.md),
        border: Border.all(
          color: isActive
              ? ParentUiColors.danger.withValues(alpha: 0.4)
              : ParentUiColors.border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? ParentUiColors.danger.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ParentUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row — type + status badge
            Row(
              children: [
                _TypeIcon(type: alert.emergencyType),
                const SizedBox(width: ParentUiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeLabel(alert.emergencyType),
                        style: ParentUiTextStyles.heading.copyWith(
                          color: isActive
                              ? ParentUiColors.danger
                              : ParentUiColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.driverName,
                        style: ParentUiTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: alert.status, color: statusColor),
              ],
            ),
            const SizedBox(height: ParentUiSpacing.md),
            // Info rows
            _InfoRow(
                icon: Icons.directions_bus_rounded, label: alert.vehicle),
            const SizedBox(height: ParentUiSpacing.xs),
            _InfoRow(
                icon: Icons.location_on_outlined, label: alert.location),
            const SizedBox(height: ParentUiSpacing.xs),
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: _formatTime(alert.triggeredAt),
            ),
            if (alert.resolvedAt != null) ...[
              const SizedBox(height: ParentUiSpacing.xs),
              _InfoRow(
                icon: Icons.check_circle_outline_rounded,
                label: 'Resolved at ${_formatTime(alert.resolvedAt!)}',
                color: ParentUiColors.success,
              ),
            ],
            // Admin action buttons
            if (isAdmin && alert.status != EmergencyStatus.resolved) ...[
              const SizedBox(height: ParentUiSpacing.md),
              const Divider(color: ParentUiColors.border, height: 1),
              const SizedBox(height: ParentUiSpacing.md),
              Row(
                children: [
                  if (alert.status == EmergencyStatus.active)
                    Expanded(
                      child: _ActionButton(
                        label: 'Acknowledge',
                        color: ParentUiColors.warning,
                        onTap: () => onAcknowledge?.call(alert.id),
                      ),
                    ),
                  if (alert.status == EmergencyStatus.active)
                    const SizedBox(width: ParentUiSpacing.sm),
                  Expanded(
                    child: _ActionButton(
                      label: 'Resolve',
                      color: ParentUiColors.success,
                      onTap: () => onResolve?.call(alert.id),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(EmergencyStatus status) => switch (status) {
        EmergencyStatus.active => ParentUiColors.danger,
        EmergencyStatus.acknowledged => ParentUiColors.warning,
        EmergencyStatus.resolved => ParentUiColors.success,
      };

  String _typeLabel(EmergencyType type) => switch (type) {
        EmergencyType.accident => 'Accident',
        EmergencyType.breakdown => 'Breakdown',
        EmergencyType.medical => 'Medical Emergency',
        EmergencyType.security => 'Security Threat',
        EmergencyType.other => 'Emergency',
      };

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final day = dt.day == DateTime.now().day ? 'Today' : '${dt.day}/${dt.month}';
    return '$day at $h:$m';
  }
}

// ---------------------------------------------------------------------------
// Small reusable card sub-widgets
// ---------------------------------------------------------------------------

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});
  final EmergencyType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      EmergencyType.accident => Icons.car_crash_rounded,
      EmergencyType.breakdown => Icons.build_rounded,
      EmergencyType.medical => Icons.medical_services_rounded,
      EmergencyType.security => Icons.security_rounded,
      EmergencyType.other => Icons.warning_rounded,
    };
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: ParentUiColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ParentUiRadius.sm),
      ),
      child: Icon(icon, color: ParentUiColors.danger, size: 26),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final EmergencyStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      EmergencyStatus.active => 'ACTIVE',
      EmergencyStatus.acknowledged => 'IN PROGRESS',
      EmergencyStatus.resolved => 'RESOLVED',
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ParentUiSpacing.sm,
        vertical: ParentUiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: ParentUiTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.color = ParentUiColors.textGrey,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: ParentUiSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: ParentUiTextStyles.caption.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(ParentUiRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: ParentUiTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / error states
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 64,
              color: ParentUiColors.success.withValues(alpha: 0.6)),
          const SizedBox(height: ParentUiSpacing.md),
          Text('No active emergencies',
              style: ParentUiTextStyles.heading
                  .copyWith(color: ParentUiColors.textGrey)),
          const SizedBox(height: ParentUiSpacing.xs),
          Text('All buses are operating safely.',
              style: ParentUiTextStyles.caption),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ParentUiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: ParentUiColors.textGrey),
            const SizedBox(height: ParentUiSpacing.md),
            Text(message,
                textAlign: TextAlign.center,
                style: ParentUiTextStyles.body
                    .copyWith(color: ParentUiColors.textGrey)),
            const SizedBox(height: ParentUiSpacing.lg),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: ParentUiSpacing.lg,
                    vertical: ParentUiSpacing.sm),
                decoration: BoxDecoration(
                  color: ParentUiColors.orange,
                  borderRadius: BorderRadius.circular(ParentUiRadius.sm),
                ),
                child: Text('Retry',
                    style: ParentUiTextStyles.body.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
