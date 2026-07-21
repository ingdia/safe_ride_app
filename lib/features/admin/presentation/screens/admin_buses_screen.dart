import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class AdminBusesScreen extends StatelessWidget {
  const AdminBusesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ParentUiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fleet Management', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.xs),
              Text('Monitor buses, routes, and maintenance status.', style: ParentUiTextStyles.caption),
              const SizedBox(height: ParentUiSpacing.lg),
              _FleetRow(bus: 'Bus 01', route: 'Kacyiru Loop', status: 'On time'),
              const SizedBox(height: ParentUiSpacing.sm),
              _FleetRow(bus: 'Bus 04', route: 'Kigali Heights', status: 'Delayed 8 min'),
              const SizedBox(height: ParentUiSpacing.sm),
              _FleetRow(bus: 'Bus 09', route: 'Gikondo', status: 'Maintenance'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FleetRow extends StatelessWidget {
  const _FleetRow({required this.bus, required this.route, required this.status});

  final String bus;
  final String route;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ParentUiRadius.lg),
        border: Border.all(color: ParentUiColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: ParentUiColors.lightOrange,
              borderRadius: BorderRadius.circular(ParentUiRadius.md),
            ),
            child: const Icon(Icons.directions_bus_rounded, color: ParentUiColors.orange),
          ),
          const SizedBox(width: ParentUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bus, style: ParentUiTextStyles.heading),
                const SizedBox(height: ParentUiSpacing.xs),
                Text(route, style: ParentUiTextStyles.caption),
              ],
            ),
          ),
          Text(status, style: ParentUiTextStyles.caption.copyWith(color: ParentUiColors.orange, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
