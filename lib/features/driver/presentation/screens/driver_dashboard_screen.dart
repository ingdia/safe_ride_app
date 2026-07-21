import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ParentUiSpacing.lg),
          child: ListView(
            children: [
              Text('Driver Dashboard', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.sm),
              Text(
                'Welcome back, driver. Your route and student updates are ready.',
                style: ParentUiTextStyles.caption,
              ),
              const SizedBox(height: ParentUiSpacing.lg),
              Container(
                padding: const EdgeInsets.all(ParentUiSpacing.md),
                decoration: parentCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today’s plan', style: ParentUiTextStyles.heading),
                    const SizedBox(height: ParentUiSpacing.sm),
                    Text(
                      '5 stops • 12 students • Route A',
                      style: ParentUiTextStyles.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ParentUiSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(ParentUiSpacing.md),
                      decoration: parentCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.route_rounded, color: ParentUiColors.orange),
                          const SizedBox(height: ParentUiSpacing.sm),
                          Text('Route', style: ParentUiTextStyles.heading),
                          Text('Open your route view', style: ParentUiTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: ParentUiSpacing.md),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(ParentUiSpacing.md),
                      decoration: parentCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.groups_rounded, color: ParentUiColors.orange),
                          const SizedBox(height: ParentUiSpacing.sm),
                          Text('Attendance', style: ParentUiTextStyles.heading),
                          Text('Update student status', style: ParentUiTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
