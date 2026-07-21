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
          child: ListView(
            children: [
              Text('Profile', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.sm),
              Text('Driver profile settings', style: ParentUiTextStyles.caption),
              const SizedBox(height: ParentUiSpacing.lg),
              Container(
                padding: const EdgeInsets.all(ParentUiSpacing.md),
                decoration: parentCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: ParentUiColors.lightOrange,
                      child: Icon(Icons.person, color: ParentUiColors.orange, size: 32),
                    ),
                    const SizedBox(height: ParentUiSpacing.md),
                    Text('Bob Driver', style: ParentUiTextStyles.heading),
                    const SizedBox(height: ParentUiSpacing.sm),
                    Text('Driver • Bus #12', style: ParentUiTextStyles.body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
