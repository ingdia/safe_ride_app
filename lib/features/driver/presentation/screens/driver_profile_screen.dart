import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

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
              Text('Profile', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.sm),
              Text('Driver profile settings', style: ParentUiTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
