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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Driver Dashboard', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.sm),
              Text(
                'Welcome, Driver',
                style: ParentUiTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
