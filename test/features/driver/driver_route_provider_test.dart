import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/driver/data/repositories/mock_driver_repository.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_provider.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_state.dart';
import 'package:safe_ride_app/shared/providers/attendance_cache_provider.dart';
import 'package:safe_ride_app/shared/providers/connectivity_provider.dart';

import '../../helpers/fake_attendance_cache_service.dart';

void main() {
  test('driver route provider initializes without late initialization errors', () async {
    // Overrides mirror the rest of the driver test suite: a fake cache (no
    // Hive box needed) and MockDriverRepository (no live Firebase needed) so
    // this test exercises DriverRouteNotifier.build() in isolation.
    final container = ProviderContainer(
      overrides: [
        attendanceCacheProvider.overrideWithValue(FakeAttendanceCacheService()),
        connectivityProvider.overrideWithValue(const AsyncData(true)),
        driverRepositoryProvider.overrideWithValue(MockDriverRepository()),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(driverRouteProvider.future),
      completion(isA<DriverRouteState>()),
    );
  });
}
