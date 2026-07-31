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

  void _updateStatus(WidgetRef ref, Student student, AttendanceStatus status) {
    ref.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
      studentId: student.id,
      status: status,
    );
  }

  int _countFor(List<Student> students, AttendanceStatus status) =>
      students.where((s) => s.status == status).length;

  /// Merges a live Firestore roster with the notifier's local attendance state.
  ///
  /// For each student in [liveRoster]:
  /// - If the notifier already holds an attendance mark for that student,
  ///   the local mark wins (driver taps are not overwritten by Firestore).
  /// - Students present in [liveRoster] but absent from [localStudents] are
  ///   appended as-is (Admin added them mid-trip).
  /// - Students in [localStudents] but absent from [liveRoster] are dropped
  ///   (Admin removed them mid-trip).
  List<Student> _mergeRoster(
    List<Student> liveRoster,
    List<Student> localStudents,
  ) {
    final localById = {for (final s in localStudents) s.id: s};
    return liveRoster.map((live) {
      final local = localById[live.id];
      if (local == null) return live;
      // Keep local attendance mark; refresh name/stop/grade from Firestore.
      return live.copyWith(status: local.status);
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(driverRouteProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: routeAsync.when(
          data: (routeState) {
            if (routeState is DriverRouteLoading || routeState is DriverRouteInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (routeState is DriverRouteError) {
              return Center(child: Text('Unable to load attendance: ${routeState.message}'));
            }

            final loaded = routeState as DriverRouteLoaded;
            return _LiveRosterBody(
              loaded: loaded,
              onSetStatus: (student, status) => _updateStatus(ref, student, status),
              countFor: _countFor,
              mergeRoster: _mergeRoster,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Unable to load attendance: $error')),
        ),
      ),
    );
  }

}

/// Inner widget that watches [studentRosterStreamProvider] when a [routeId] is
/// available, merging the live Firestore roster with the notifier's local
/// attendance state before rendering.
class _LiveRosterBody extends ConsumerWidget {
  const _LiveRosterBody({
    required this.loaded,
    required this.onSetStatus,
    required this.countFor,
    required this.mergeRoster,
  });

  final DriverRouteLoaded loaded;
  final void Function(Student, AttendanceStatus) onSetStatus;
  final int Function(List<Student>, AttendanceStatus) countFor;
  final List<Student> Function(List<Student>, List<Student>) mergeRoster;

  // Expose the same header/stop-header builders via the parent's static helpers.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Derive routeId/busId from the notifier's resolved metadata (non-empty
    // only when FirestoreDriverRepository successfully fetched route
    // metadata). The roster stream is keyed by busId, not routeId — see
    // DriverStreamService.studentsStream.
    final routeDataAsync = ref.watch(routeDataStreamProvider(loaded.routeId ?? ''));
    final rosterAsync = ref.watch(studentRosterStreamProvider(loaded.busId ?? ''));

    // Resolve the student list: live Firestore roster merged with local marks,
    // or fall back to the notifier's list when the stream hasn't emitted yet.
    final students = rosterAsync.maybeWhen(
      data: (liveRoster) => liveRoster.isEmpty
          ? loaded.students
          : mergeRoster(liveRoster, loaded.students),
      orElse: () => loaded.students,
    );

    // Show a subtle live-indicator badge when the stream is active.
    final isLive = routeDataAsync.hasValue && (loaded.routeId ?? '').isNotEmpty;

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
        if (isLive) ...
          [
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.success),
                const SizedBox(width: AppSpacing.xs),
                Text('Live roster', style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
              ],
            ),
          ],
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
              Expanded(child: _SummaryPill(label: 'Waiting', count: countFor(students, AttendanceStatus.notBoarded), color: AppColors.warning)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _SummaryPill(label: 'Boarded', count: countFor(students, AttendanceStatus.boarded), color: AppColors.success)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _SummaryPill(label: 'Dropped Off', count: countFor(students, AttendanceStatus.absent), color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...stopOrder.expand((stopName) => [
              _buildStopHeader(stopName),
              ...byStop[stopName]!.map((student) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _StudentListItem(
                      student: student,
                      onSetStatus: (status) => onSetStatus(student, status),
                    ),
                  )),
            ]),
      ],
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
  const _StudentListItem({
    required this.student,
    required this.onSetStatus,
  });

  final Student student;
  final ValueChanged<AttendanceStatus> onSetStatus;

  @override
  Widget build(BuildContext context) {
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
            Flexible(
              fit: FlexFit.loose,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _StatusToggleButton(
                    label: 'Boarded',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    selected: student.status == AttendanceStatus.boarded,
                    onTap: () => onSetStatus(AttendanceStatus.boarded),
                  ),
                  _StatusToggleButton(
                    label: 'Waiting',
                    icon: Icons.pending_outlined,
                    color: AppColors.warning,
                    selected: student.status == AttendanceStatus.notBoarded,
                    onTap: () => onSetStatus(AttendanceStatus.notBoarded),
                  ),
                  _StatusToggleButton(
                    label: 'Dropped Off',
                    icon: Icons.keyboard_double_arrow_right_rounded,
                    color: AppColors.textSecondary,
                    selected: student.status == AttendanceStatus.absent,
                    onTap: () => onSetStatus(AttendanceStatus.absent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusToggleButton extends StatelessWidget {
  const _StatusToggleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: selected ? color : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? color : AppColors.textSecondary, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: AppTextStyles.bodySmall.copyWith(color: selected ? color : AppColors.textSecondary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
