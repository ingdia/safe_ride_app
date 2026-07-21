import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

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
              Text('System Settings', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.xs),
              Text('Configure app-wide admin preferences and operational rules.', style: ParentUiTextStyles.caption),
              const SizedBox(height: ParentUiSpacing.lg),
              _SettingRow(title: 'Notifications', value: 'Enabled'),
              const SizedBox(height: ParentUiSpacing.sm),
              _SettingRow(title: 'Auto-alerts', value: 'On'),
              const SizedBox(height: ParentUiSpacing.sm),
              _SettingRow(title: 'Driver Approval', value: 'Manual'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.title, required this.value});

  final String title;
  final String value;

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
          Expanded(child: Text(title, style: ParentUiTextStyles.heading)),
          Text(value, style: ParentUiTextStyles.caption.copyWith(color: ParentUiColors.orange, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
