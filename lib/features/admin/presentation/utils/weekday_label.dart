const List<String> _weekdayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String weekdayLabel(String isoDate) {
  final date = DateTime.parse(isoDate);
  return _weekdayLabels[date.weekday - 1];
}
