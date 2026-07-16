import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/student.dart';

/// Driver's "Student Attendance List" screen.
///
/// Lets the driver see every student on the current route and mark them
/// as boarded / not boarded / absent (Fig. 4 & Fig. 5 flows — "Live List
/// of Students", "Mark as Boarded / Dropped Off / Absent").
///
/// NOTE: Status changes are currently held in local widget state only.
/// Task 2 (feature/driver-bloc) will move this to `DriverRouteBloc` so
/// that marking a student triggers the parent notification described in
/// the user flow.
class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  // TODO(Task 2): Replace with data from DriverRouteBloc / DriverRepository.
  final List<Student> _students = const [
    Student(
      id: 's1',
      name: 'Emma Johnson',
      stopName: 'Oak Street',
      grade: 'Grade 3',
    ),
    Student(
      id: 's2',
      name: 'Liam Uwimana',
      stopName: 'Oak Street',
      grade: 'Grade 2',
    ),
    Student(
      id: 's3',
      name: 'Aline Mukamana',
      stopName: 'Oak Street',
      grade: 'Grade 4',
    ),
    Student(
      id: 's4',
      name: 'Noah Habimana',
      stopName: 'Maple Avenue',
      grade: 'Grade 1',
    ),
    Student(
      id: 's5',
      name: 'Grace Ineza',
      stopName: 'Maple Avenue',
      grade: 'Grade 3',
    ),
  ].map((s) => s).toList();

  void _cycleStatus(String studentId) {
    setState(() {
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index == -1) return;

      final current = _students[index].status;
      final next = switch (current) {
        AttendanceStatus.notBoarded => AttendanceStatus.boarded,
        AttendanceStatus.boarded => AttendanceStatus.absent,
        AttendanceStatus.absent => AttendanceStatus.notBoarded,
      };

      _students[index] = _students[index].copyWith(status: next);

      // TODO(Task 2): Dispatch MarkStudentStatusEvent(studentId, next) to
      // DriverRouteBloc, which will trigger the parent notification.
    });
  }

  int _countFor(AttendanceStatus status) =>
      _students.where((s) => s.status == status).length;

  @override
  Widget build(BuildContext context) {
    // Group students by stop, preserving first-seen order.
    final stopOrder = <String>[];
    final byStop = <String, List<Student>>{};
    for (final student in _students) {
      if (!byStop.containsKey(student.stopName)) {
        stopOrder.add(student.stopName);
        byStop[student.stopName] = [];
      }
      byStop[student.stopName]!.add(student);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSummaryRow(context)),
            for (final stopName in stopOrder) ...[
              SliverToBoxAdapter(child: _buildStopHeader(stopName)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = byStop[stopName]![index];
                      return _StudentListItem(
                        student: student,
                        onTap: () => _cycleStatus(student.id),
                      );
                    },
                    childCount: byStop[stopName]!.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Attendance', style: AppTextStyles.headingLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap a student to update their status',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _SummaryPill(
            label: 'Boarded',
            count: _countFor(AttendanceStatus.boarded),
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          _SummaryPill(
            label: 'Not Boarded',
            count: _countFor(AttendanceStatus.notBoarded),
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          _SummaryPill(
            label: 'Absent',
            count: _countFor(AttendanceStatus.absent),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStopHeader(String stopName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            stopName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTextStyles.headingSmall.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single student row with a tappable status chip.
///
/// Extracted as a private widget here for now; move to
/// `widgets/student_list_item.dart` if reused elsewhere.
class _StudentListItem extends StatelessWidget {
  const _StudentListItem({
    required this.student,
    required this.onTap,
  });

  final Student student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: ConstrainedBox(
            // Ensures the whole row meets the 48dp min tap target even
            // if content is short.
            constraints: const BoxConstraints(
              minHeight: AppSpacing.tapTargetMin + 16,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name.substring(0, 1)
                          : '?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.name, style: AppTextStyles.bodyMedium),
                        Text(
                          student.grade,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AttendanceStatusChip(status: student.status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small colored chip showing a student's current attendance status.
///
/// Extracted as a private widget here for now; move to
/// `widgets/attendance_status_chip.dart` if reused elsewhere.
class _AttendanceStatusChip extends StatelessWidget {
  const _AttendanceStatusChip({required this.status});

  final AttendanceStatus status;

  ({Color color, String label, IconData icon}) get _visuals => switch (
      status) {
    AttendanceStatus.boarded => (
        color: AppColors.success,
        label: 'Boarded',
        icon: Icons.check_circle_rounded,
      ),
    AttendanceStatus.notBoarded => (
        color: AppColors.warning,
        label: 'Not Boarded',
        icon: Icons.radio_button_unchecked_rounded,
      ),
    AttendanceStatus.absent => (
        color: AppColors.error,
        label: 'Absent',
        icon: Icons.cancel_rounded,
      ),
  };

  @override
  Widget build(BuildContext context) {
    final visuals = _visuals;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: visuals.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visuals.icon, size: 16, color: visuals.color),
          const SizedBox(width: 4),
          Text(
            visuals.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: visuals.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}