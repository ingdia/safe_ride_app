import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/main.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_navigation_provider.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_provider.dart';
import 'package:safe_ride_app/features/driver/presentation/providers/driver_route_state.dart';
import 'package:safe_ride_app/features/driver/presentation/screens/driver_dashboard_screen.dart';
import 'package:safe_ride_app/shared/providers/attendance_cache_provider.dart';
import 'package:safe_ride_app/shared/providers/connectivity_provider.dart';

import 'helpers/fake_attendance_cache_service.dart';

void main() {
  // Your basic smoke test
  testWidgets('SafeRideApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SafeRideApp()));
    expect(find.byType(SafeRideApp), findsOneWidget);
  });

  testWidgets('dashboard quick action switches to the roster tab', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: DriverDashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('View roster'));
    await tester.pump();

    expect(container.read(driverNavigationProvider), 2);
  });

  // Your colleague's attendance test
  test('attendance updates emit progress metadata', () async {
    final cache = FakeAttendanceCacheService();
    final container = ProviderContainer(
      overrides: [
        attendanceCacheProvider.overrideWithValue(cache),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(driverRouteProvider.future);
    await container.read(driverRouteProvider.notifier).updateStudentAttendanceStatus(
          studentId: 's1',
          status: AttendanceStatus.boarded,
        );

    final state = container.read(driverRouteProvider);
    expect(state.value, isA<DriverRouteLoaded>());

    final loaded = state.value as DriverRouteLoaded;
    expect(loaded.routeProgress, greaterThan(0.0));
    expect(loaded.gpsStatus, contains('Route progress'));
  });
}