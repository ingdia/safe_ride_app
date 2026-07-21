import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

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
              Text('User Management', style: ParentUiTextStyles.title),
              const SizedBox(height: ParentUiSpacing.xs),
              Text('Review parents, drivers, and account requests.', style: ParentUiTextStyles.caption),
              const SizedBox(height: ParentUiSpacing.lg),
              _UserRow(name: 'Alice Parent', role: 'Parent', status: 'Active'),
              const SizedBox(height: ParentUiSpacing.sm),
              _UserRow(name: 'Bob Driver', role: 'Driver', status: 'Pending review'),
              const SizedBox(height: ParentUiSpacing.sm),
              _UserRow(name: 'Carol Admin', role: 'Admin', status: 'Active'),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.name, required this.role, required this.status});

  final String name;
  final String role;
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
          CircleAvatar(
            radius: 24,
            backgroundColor: ParentUiColors.lightOrange,
            child: const Icon(Icons.person_rounded, color: ParentUiColors.orange),
          ),
          const SizedBox(width: ParentUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: ParentUiTextStyles.heading),
                const SizedBox(height: ParentUiSpacing.xs),
                Text(role, style: ParentUiTextStyles.caption),
              ],
            ),
          ),
          Text(status, style: ParentUiTextStyles.caption.copyWith(color: ParentUiColors.orange, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
