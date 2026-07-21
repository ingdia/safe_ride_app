import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
              Text('Admin Dashboard', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.xs),
              Text(
                'Overview of fleet activity, alerts, and operational health.',
                style: ParentUiTextStyles.caption,
              ),
              const SizedBox(height: ParentUiSpacing.lg),
              _SummaryCard(title: 'Active Buses', value: '18', detail: '2 need attention'),
              const SizedBox(height: ParentUiSpacing.md),
              _SummaryCard(title: 'Pending Drivers', value: '6', detail: 'Awaiting approval'),
              const SizedBox(height: ParentUiSpacing.md),
              _SummaryCard(title: 'Open Alerts', value: '3', detail: '1 emergency, 2 delays'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.detail,
  });

  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ParentUiRadius.lg),
        border: Border.all(color: ParentUiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ParentUiTextStyles.heading.copyWith(fontSize: 18)),
          const SizedBox(height: ParentUiSpacing.sm),
          Text(value, style: ParentUiTextStyles.title.copyWith(fontSize: 28)),
          const SizedBox(height: ParentUiSpacing.xs),
          Text(detail, style: ParentUiTextStyles.caption),
        ],
      ),
    );
  }
}
