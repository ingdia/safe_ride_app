import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/student.dart';
import '../providers/driver_route_provider.dart';
import '../providers/driver_route_state.dart';

class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  void _toggleStatus(WidgetRef ref, Student student) {
    final next = switch (student.status) {
      AttendanceStatus.notBoarded => AttendanceStatus.boarded,
      AttendanceStatus.boarded => AttendanceStatus.notBoarded,
      AttendanceStatus.absent => AttendanceStatus.notBoarded,
    };

    ref.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
      studentId: student.id,
      status: next,
    );
  }

  int _countFor(List<Student> students, AttendanceStatus status) =>
      students.where((s) => s.status == status).length;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverRouteProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.when(
          data: (routeState) {
            if (routeState is DriverRouteLoading || routeState is DriverRouteInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (routeState is DriverRouteError) {
              return Center(child: Text('Unable to load attendance: ${routeState.message}'));
            }

            final students = (routeState as DriverRouteLoaded).students;
            final stopOrder = <String>[];
            final byStop = <String, List<Student>>{};
            for (final student in students) {
              if (!byStop.containsKey(student.stopName)) {
                stopOrder.add(student.stopName);
                byStop[student.stopName] = [];
              }
              byStop[student.stopName]!.add(student);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _SummaryPill(label: 'Waiting', count: _countFor(students, AttendanceStatus.notBoarded), color: AppColors.warning)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _SummaryPill(label: 'On Board', count: _countFor(students, AttendanceStatus.boarded), color: AppColors.success)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...stopOrder.expand((stopName) => [
                      _buildStopHeader(stopName),
                      ...byStop[stopName]!.map((student) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _StudentListItem(student: student, onTap: () => _toggleStatus(ref, student)),
                          )),
                    ]),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Unable to load attendance: $error')),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student roster', style: AppTextStyles.headingLarge),
        const SizedBox(height: AppSpacing.xs),
        Text('Tap a student to update their boarding status in real time.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStopHeader(String stopName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(stopName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text('$count', style: AppTextStyles.headingSmall.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _StudentListItem extends StatelessWidget {
  const _StudentListItem({required this.student, required this.onTap});

  final Student student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBoarded = student.status == AttendanceStatus.boarded;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(student.name.isNotEmpty ? student.name.substring(0, 1) : '?', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text('${student.stopName} • ${student.grade}', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isBoarded ? AppColors.success.withValues(alpha: 0.12) : AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(isBoarded ? 'On Board' : 'Waiting', style: AppTextStyles.bodySmall.copyWith(color: isBoarded ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              height: AppSpacing.tapTargetMin,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                ),
                child: Text(isBoarded ? 'Mark as Waiting' : 'Check In'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call_outlined, color: AppColors.primary),
              tooltip: 'Call student',
            ),
          ],
        ),
      ),
    );
  }
}
