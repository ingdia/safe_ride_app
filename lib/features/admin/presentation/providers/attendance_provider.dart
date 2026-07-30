import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';
import 'routes_provider.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(firestoreProvider));
});

final attendanceProvider = StreamProvider<List<AttendanceModel>>((ref) async* {
  final routes = ref.watch(routesListProvider);
  final routeIds = routes.map((r) => r.routeId).toList();
  yield* ref.read(attendanceRepositoryProvider).streamLast7Days(routeIds);
});

final attendanceListProvider = Provider<List<AttendanceModel>>((ref) {
  return ref.watch(attendanceProvider).value ?? [];
});

class DailyAttendanceRate {
  final String date;
  final int presentCount;
  final int totalCount;
  final double ratePercent;

  const DailyAttendanceRate({
    required this.date,
    required this.presentCount,
    required this.totalCount,
    required this.ratePercent,
  });
}

final dailyAttendanceRatesProvider = Provider<List<DailyAttendanceRate>>((ref) {
  final records = ref.watch(attendanceListProvider);
  final byDate = <String, List<AttendanceModel>>{};

  for (final record in records) {
    byDate.putIfAbsent(record.date, () => []).add(record);
  }

  final sortedDates = byDate.keys.toList()..sort();

  return sortedDates.map((date) {
    final dayRecords = byDate[date]!;
    final present =
        dayRecords.where((r) => r.status == AttendanceStatus.boarded).length;
    final total = dayRecords.length;
    final rate = total == 0 ? 0.0 : (present / total) * 100;
    return DailyAttendanceRate(
      date: date,
      presentCount: present,
      totalCount: total,
      ratePercent: rate,
    );
  }).toList();
});
