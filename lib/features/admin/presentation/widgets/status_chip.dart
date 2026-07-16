import 'package:flutter/material.dart';
import '../providers/fleet_overview_provider.dart';
import 'admin_ui_constants.dart';

class StatusChip extends StatelessWidget {
  final FleetBusStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isOnTime = status == FleetBusStatus.onTime;
    final bg = isOnTime ? AdminUiColors.onTimeBg : AdminUiColors.delayedBg;
    final fg = isOnTime ? AdminUiColors.onTimeFg : AdminUiColors.delayedFg;
    final icon = isOnTime
        ? Icons.check_circle_rounded
        : Icons.access_time_filled_rounded;
    final label = isOnTime ? 'On Time' : 'Delayed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AdminUiRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
