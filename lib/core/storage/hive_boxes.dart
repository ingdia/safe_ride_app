import 'package:hive_flutter/hive_flutter.dart';
import '../../features/driver/data/models/cached_attendance_record.dart';

abstract class HiveBoxes {
  static const String offlineAttendance = 'offline_attendance';
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CachedAttendanceRecordAdapter());
  await Hive.openBox<CachedAttendanceRecord>(HiveBoxes.offlineAttendance);
}
