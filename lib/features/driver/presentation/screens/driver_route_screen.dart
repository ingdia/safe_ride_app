import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class DriverRouteScreen extends StatelessWidget {
  const DriverRouteScreen({super.key});

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
              Text('My Route', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.sm),
              Text('Today\'s route details', style: ParentUiTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
