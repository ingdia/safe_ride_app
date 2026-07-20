import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:safe_ride_app/main.dart';
import 'package:safe_ride_app/features/driver/data/repositories/mock_driver_repository.dart';
import 'package:safe_ride_app/features/driver/domain/models/student.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_bloc.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_event.dart';
import 'package:safe_ride_app/features/driver/presentation/bloc/driver_route_state.dart';

import 'helpers/fake_attendance_cache_service.dart';

void main() {
  // Your basic smoke test
  testWidgets('SafeRideApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SafeRideApp()));
    expect(find.byType(SafeRideApp), findsOneWidget);
  });

  // Your colleague's attendance test
  test('attendance updates emit progress metadata', () async {
    final bloc = DriverRouteBloc(
      repository: MockDriverRepository(),
      cacheService: FakeAttendanceCacheService(),
      isOnline: true,
    );
    addTearDown(bloc.close);

    bloc.add(const LoadDriverRoute());
    await Future<void>.delayed(const Duration(milliseconds: 200));
    print('after load: ${bloc.state.runtimeType}');
    if (bloc.state is DriverRouteError) {
      print((bloc.state as DriverRouteError).message);
    }
    expect(bloc.state, isA<DriverRouteLoaded>());

    bloc.add(const UpdateStudentAttendanceStatus(
      studentId: 's1',
      status: AttendanceStatus.boarded,
    ));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final loaded = bloc.state as DriverRouteLoaded;
    expect(loaded.routeProgress, greaterThan(0.0));
    expect(loaded.gpsStatus, contains('Route progress'));
  });
}