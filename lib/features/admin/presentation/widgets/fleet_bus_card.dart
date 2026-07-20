import 'package:flutter/material.dart';
import '../providers/fleet_overview_provider.dart';
import 'admin_ui_constants.dart';
import 'round_icon_button.dart';
import 'status_chip.dart';

class FleetBusCard extends StatelessWidget {
  final FleetBusSummary summary;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FleetBusCard({
    super.key,
    required this.summary,
    this.onEdit,
    this.onDelete,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AdminUiColors.statCardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus_filled_rounded,
              color: AdminUiColors.primaryOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: AdminUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bus ${summary.plateNumber}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    StatusChip(status: summary.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  summary.driverName,
                  style: const TextStyle(
                    color: AdminUiColors.primaryOrange,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: AdminUiSpacing.md,
                  runSpacing: 4,
                  children: [
                    _InlineMeta(
                      icon: Icons.groups_2_outlined,
                      text: '${summary.capacity} students',
                    ),
                    _InlineMeta(
                      icon: Icons.location_on_outlined,
                      text: summary.routeName,
                    ),
                  ],
                ),
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(height: AdminUiSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        RoundIconButton(
                          icon: Icons.edit_outlined,
                          background: AdminUiColors.infoBg,
                          foreground: AdminUiColors.infoFg,
                          onTap: onEdit!,
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 8),
                      if (onDelete != null)
                        RoundIconButton(
                          icon: Icons.delete_outline,
                          background: AdminUiColors.dangerBg,
                          foreground: AdminUiColors.dangerFg,
                          onTap: onDelete!,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InlineMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AdminUiColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AdminUiColors.textSecondary,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
