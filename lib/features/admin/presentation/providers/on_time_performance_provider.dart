import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnTimeDataPoint {
  final String date;
  final double onTimePercent;

  const OnTimeDataPoint({required this.date, required this.onTimePercent});
}

final Map<int, double> _mockOnTimeByDayOffset = {
  6: 91,
  5: 88,
  4: 95,
  3: 90,
  2: 93,
  1: 96,
  0: 94,
};

String _isoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

final onTimePerformanceProvider = Provider<List<OnTimeDataPoint>>((ref) {
  final today = DateTime.now();
  final entries = _mockOnTimeByDayOffset.entries.toList()
    ..sort((a, b) => b.key.compareTo(a.key));

  return entries.map((entry) {
    final day = today.subtract(Duration(days: entry.key));
    return OnTimeDataPoint(date: _isoDate(day), onTimePercent: entry.value);
  }).toList();
});
