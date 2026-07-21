import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class DriverRouteScreen extends StatelessWidget {
  const DriverRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stops = [
      'Oak Street • 7:45 AM',
      'Maple Avenue • 7:52 AM',
      'Cedar Lane • 8:00 AM',
      'Birch Court • 8:07 AM',
    ];

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ParentUiSpacing.lg),
          child: ListView(
            children: [
              Text('My Route', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.sm),
              Text('Today’s route overview', style: ParentUiTextStyles.caption),
              const SizedBox(height: ParentUiSpacing.lg),
              Container(
                padding: const EdgeInsets.all(ParentUiSpacing.md),
                decoration: parentCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Route A', style: ParentUiTextStyles.heading),
                    const SizedBox(height: ParentUiSpacing.sm),
                    Text('Bus #12 • 12 students', style: ParentUiTextStyles.body),
                  ],
                ),
              ),
              const SizedBox(height: ParentUiSpacing.md),
              ...stops.map((stop) => Padding(
                    padding: const EdgeInsets.only(bottom: ParentUiSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(ParentUiSpacing.md),
                      decoration: parentCardDecoration(),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: ParentUiColors.orange),
                          const SizedBox(width: ParentUiSpacing.sm),
                          Expanded(child: Text(stop, style: ParentUiTextStyles.body)),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
