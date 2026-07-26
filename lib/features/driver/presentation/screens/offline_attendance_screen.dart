import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/providers/attendance_cache_provider.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../data/datasources/attendance_cache_service.dart';
import '../../data/models/cached_attendance_record.dart';
import '../../domain/models/student.dart';
import '../providers/driver_route_provider.dart';
import '../providers/driver_route_state.dart';

class OfflineAttendanceScreen extends ConsumerStatefulWidget {
  const OfflineAttendanceScreen({super.key});

  @override
  ConsumerState<OfflineAttendanceScreen> createState() => _OfflineAttendanceScreenState();
}

class _OfflineAttendanceScreenState extends ConsumerState<OfflineAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(driverRouteProvider);
    final connectivity = ref.watch(connectivityProvider);
    final cacheService = ref.watch(attendanceCacheProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offline attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: routeState.when(
          data: (state) {
            if (state is! DriverRouteLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final students = state.students;
            final online = connectivity.maybeWhen(data: (value) => value, orElse: () => true);
            final cachedRecords = cacheService.loadAll();
            final cachedCount = cachedRecords.length;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(online ? Icons.wifi_rounded : Icons.wifi_off_rounded, color: online ? AppColors.success : AppColors.warning),
                          const SizedBox(width: AppSpacing.sm),
                          Text(online ? 'Online • sync ready' : 'Offline — save locally', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(online ? 'Attendance updates will sync immediately.' : 'Attendance marks are saved locally and will sync when connectivity returns.', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Pending local saves', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                Text('$cachedCount local record${cachedCount == 1 ? '' : 's'} waiting to sync', style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.md),
                ...students.map((student) => _OfflineStudentTile(student: student, online: online, cacheService: cacheService)),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.tapTargetMin + 8,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Return to driver route'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Unable to load attendance: $error')),
        ),
      ),
    );
  }
}

class _OfflineStudentTile extends StatelessWidget {
  const _OfflineStudentTile({required this.student, required this.online, required this.cacheService});

  final Student student;
  final bool online;
  final AttendanceCacheService cacheService;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(student.stopName, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            height: AppSpacing.tapTargetMin,
            child: ElevatedButton(
              onPressed: online ? null : () async {
                final nextStatus = student.status == AttendanceStatus.boarded ? AttendanceStatus.notBoarded : AttendanceStatus.boarded;
                await cacheService.saveRecord(
                  CachedAttendanceRecord(
                    studentId: student.id,
                    studentName: student.name,
                    stopName: student.stopName,
                    statusIndex: nextStatus.index,
                    recordedAt: DateTime.now(),
                    synced: false,
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance saved offline')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(online ? 'Sync ready' : 'Save offline'),
            ),
          ),
        ],
      ),
    );
  }
}
