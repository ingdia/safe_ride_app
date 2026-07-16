import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/student_model.dart';
import 'students_provider.dart';

String _busIdForRoute(String routeId) {
  switch (routeId) {
    case 'route-a':
      return 'bus-12';
    case 'route-b':
      return 'bus-07';
    case 'route-c':
      return 'bus-15';
    case 'route-d':
      return 'bus-03';
    default:
      return 'bus-12';
  }
}

String _isoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

List<AttendanceModel> _buildSeedAttendance(List<StudentModel> students) {
  final today = DateTime.now();
  final absentSlots = <String>{'2-3', '4-1', '0-6', '3-2', '5-0'};
  final records = <AttendanceModel>[];

  for (var dayOffset = 6; dayOffset >= 0; dayOffset--) {
    final day = today.subtract(Duration(days: dayOffset));
    final dateString = _isoDate(day);

    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final isAbsent = absentSlots.contains('$i-$dayOffset');
      records.add(
        AttendanceModel(
          attendanceId: 'att-$dayOffset-${student.studentId}',
          studentId: student.studentId,
          routeId: student.routeId,
          busId: _busIdForRoute(student.routeId),
          status:
              isAbsent ? AttendanceStatus.absent : AttendanceStatus.boarded,
          date: dateString,
          timestamp: DateTime(day.year, day.month, day.day, 7, 30),
          recordedBy: 'user-admin-1',
        ),
      );
    }
  }
  return records;
}

final attendanceProvider = Provider<List<AttendanceModel>>((ref) {
  final students = ref.watch(studentsProvider);
  return _buildSeedAttendance(students);
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

final dailyAttendanceRatesProvider =
    Provider<List<DailyAttendanceRate>>((ref) {
  final records = ref.watch(attendanceProvider);
  final byDate = <String, List<AttendanceModel>>{};

  for (final record in records) {
    byDate.putIfAbsent(record.date, () => []).add(record);
  }

  final sortedDates = byDate.keys.toList()..sort();

  return sortedDates.map((date) {
    final dayRecords = byDate[date]!;
    final present =
        dayRecords.where((r) => r.status != AttendanceStatus.absent).length;
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
