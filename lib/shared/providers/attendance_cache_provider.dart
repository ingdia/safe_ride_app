import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/driver/data/datasources/attendance_cache_service.dart';

final attendanceCacheProvider = Provider<AttendanceCacheService>(
  (_) => AttendanceCacheService(),
);
