import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../providers/users_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(schoolUsersProvider);

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: usersAsync.when(
                  loading: () => const HeaderTitleBlock(
                    title: 'User Management',
                    subtitle: 'Loading…',
                  ),
                  error: (e, st) => const HeaderTitleBlock(
                    title: 'User Management',
                    subtitle: 'Could not load users',
                  ),
                  data: (users) => HeaderTitleBlock(
                    title: 'User Management',
                    subtitle: '${users.length} user${users.length == 1 ? '' : 's'}',
                  ),
                ),
              ),
            ),
            usersAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AdminUiColors.primaryOrange,
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    e.toString(),
                    style: const TextStyle(color: AdminUiColors.dangerFg),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (users) => SliverPadding(
                padding: const EdgeInsets.all(AdminUiSpacing.md),
                sliver: users.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No users found for this school.',
                            style: TextStyle(
                              color: AdminUiColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: users.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AdminUiSpacing.sm),
                        itemBuilder: (context, index) =>
                            _UserRow(user: users[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final roleLabel = _roleLabel(user.role);
    final statusLabel = _statusLabel(user);
    final statusColor = _statusColor(user);

    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AdminUiColors.statCardBackground,
            child: const Icon(
              Icons.person_rounded,
              color: AdminUiColors.primaryOrange,
            ),
          ),
          const SizedBox(width: AdminUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roleLabel,
                  style: const TextStyle(
                    color: AdminUiColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AdminUiRadii.chip),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.driver:
        return 'Driver';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String _statusLabel(UserModel user) {
    if (user.role != UserRole.driver) return 'Active';
    switch (user.approvalStatus) {
      case DriverApprovalStatus.approved:
        return 'Approved';
      case DriverApprovalStatus.rejected:
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(UserModel user) {
    if (user.role != UserRole.driver) return AdminUiColors.onTimeFg;
    switch (user.approvalStatus) {
      case DriverApprovalStatus.approved:
        return AdminUiColors.onTimeFg;
      case DriverApprovalStatus.rejected:
        return AdminUiColors.dangerFg;
      default:
        return AdminUiColors.primaryOrange;
    }
  }
}
