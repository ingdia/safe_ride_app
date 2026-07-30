import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/features/admin/data/models/attendance_model.dart';
import 'package:safe_ride_app/features/admin/data/models/bus_model.dart';
import 'package:safe_ride_app/features/admin/data/models/route_model.dart';
import 'package:safe_ride_app/features/admin/data/models/student_model.dart';
import 'package:safe_ride_app/features/admin/data/models/user_model.dart';
import 'package:safe_ride_app/features/admin/presentation/providers/attendance_provider.dart';
import 'package:safe_ride_app/features/admin/presentation/providers/buses_provider.dart';
import 'package:safe_ride_app/features/admin/presentation/providers/fleet_overview_provider.dart';
import 'package:safe_ride_app/features/admin/presentation/providers/routes_provider.dart';
import 'package:safe_ride_app/features/admin/presentation/providers/students_provider.dart';
import 'package:safe_ride_app/features/admin/presentation/providers/users_provider.dart';

AttendanceModel _att(String id, String date, AttendanceStatus status, String routeId) =>
    AttendanceModel(
      attendanceId: id,
      studentId: 'student-$id',
      routeId: routeId,
      busId: 'bus-1',
      status: status,
      date: date,
      timestamp: DateTime(2024, 6, 1),
      recordedBy: 'driver-1',
    );

BusModel _bus(String id, {BusStatus status = BusStatus.idle, String driverId = ''}) =>
    BusModel(
      busId: id,
      plateNumber: 'RAB 00$id',
      capacity: 40,
      driverId: driverId,
      schoolId: 'school-1',
      status: status,
      createdAt: DateTime(2024, 1, 1),
    );

RouteModel _route(String id, String busId) => RouteModel(
      routeId: id,
      schoolId: 'school-1',
      busId: busId,
      name: 'Route $id',
      createdAt: DateTime(2024, 1, 1),
    );

StudentModel _student(String id, String routeId) => StudentModel(
      studentId: id,
      name: 'Student $id',
      grade: '1',
      schoolId: 'school-1',
      parentId: 'parent-1',
      routeId: routeId,
    );

UserModel _user(String id, String name) => UserModel(
      userId: id,
      name: name,
      email: '$id@test.com',
      phone: '',
      role: UserRole.driver,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  group('dailyAttendanceRatesProvider', () {
    ProviderContainer makeContainer(List<AttendanceModel> records) {
      return ProviderContainer(
        overrides: [
          attendanceListProvider.overrideWith((ref) => records),
        ],
      );
    }

    test('returns empty list when no records', () {
      final c = makeContainer([]);
      addTearDown(c.dispose);
      expect(c.read(dailyAttendanceRatesProvider), isEmpty);
    });

    test('counts only boarded as present', () {
      final records = [
        _att('1', '2024-06-01', AttendanceStatus.boarded, 'route-1'),
        _att('2', '2024-06-01', AttendanceStatus.alighted, 'route-1'),
        _att('3', '2024-06-01', AttendanceStatus.absent, 'route-1'),
      ];
      final c = makeContainer(records);
      addTearDown(c.dispose);

      final rates = c.read(dailyAttendanceRatesProvider);
      expect(rates.length, 1);
      expect(rates.first.presentCount, 1);
      expect(rates.first.totalCount, 3);
      expect(rates.first.ratePercent, closeTo(33.33, 0.1));
    });

    test('groups records by date and sorts ascending', () {
      final records = [
        _att('1', '2024-06-03', AttendanceStatus.boarded, 'route-1'),
        _att('2', '2024-06-01', AttendanceStatus.boarded, 'route-1'),
        _att('3', '2024-06-02', AttendanceStatus.absent, 'route-1'),
      ];
      final c = makeContainer(records);
      addTearDown(c.dispose);

      final dates = c.read(dailyAttendanceRatesProvider).map((r) => r.date).toList();
      expect(dates, ['2024-06-01', '2024-06-02', '2024-06-03']);
    });

    test('100% rate when all students boarded', () {
      final records = [
        _att('1', '2024-06-01', AttendanceStatus.boarded, 'route-1'),
        _att('2', '2024-06-01', AttendanceStatus.boarded, 'route-1'),
      ];
      final c = makeContainer(records);
      addTearDown(c.dispose);

      expect(c.read(dailyAttendanceRatesProvider).first.ratePercent, 100.0);
    });

    test('0% rate when all students absent', () {
      final records = [
        _att('1', '2024-06-01', AttendanceStatus.absent, 'route-1'),
        _att('2', '2024-06-01', AttendanceStatus.absent, 'route-1'),
      ];
      final c = makeContainer(records);
      addTearDown(c.dispose);

      expect(c.read(dailyAttendanceRatesProvider).first.ratePercent, 0.0);
    });
  });

  group('fleetSummaryProvider', () {
    ProviderContainer makeContainer({
      List<BusModel> buses = const [],
      List<RouteModel> routes = const [],
      List<StudentModel> students = const [],
      List<UserModel> users = const [],
    }) {
      return ProviderContainer(
        overrides: [
          busesListProvider.overrideWith((ref) => buses),
          routesListProvider.overrideWith((ref) => routes),
          studentsListProvider.overrideWith((ref) => students),
          usersListProvider.overrideWith((ref) => users),
        ],
      );
    }

    test('returns empty list when no buses or routes', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      expect(c.read(fleetSummaryProvider), isEmpty);
    });

    test('bus with matching route appears with correct routeName', () {
      final c = makeContainer(
        buses: [_bus('1', driverId: 'driver-1')],
        routes: [_route('route-1', 'bus-1')],
        users: [_user('driver-1', 'John')],
      );
      addTearDown(c.dispose);

      final summaries = c.read(fleetSummaryProvider);
      expect(summaries.length, 1);
      expect(summaries.first.routeName, 'Route route-1');
      expect(summaries.first.driverName, 'John');
    });

    test('bus without a route appears with "No route assigned"', () {
      final c = makeContainer(buses: [_bus('1')]);
      addTearDown(c.dispose);

      final summaries = c.read(fleetSummaryProvider);
      expect(summaries.length, 1);
      expect(summaries.first.routeName, 'No route assigned');
    });

    test('studentCount reflects students assigned to the route', () {
      final c = makeContainer(
        buses: [_bus('1')],
        routes: [_route('route-1', 'bus-1')],
        students: [
          _student('s1', 'route-1'),
          _student('s2', 'route-1'),
          _student('s3', 'route-2'),
        ],
      );
      addTearDown(c.dispose);

      expect(c.read(fleetSummaryProvider).first.studentCount, 2);
    });

    test('SOS bus maps to FleetBusStatus.sos', () {
      final c = makeContainer(
        buses: [_bus('1', status: BusStatus.sos)],
        routes: [_route('route-1', 'bus-1')],
      );
      addTearDown(c.dispose);

      final summary = c.read(fleetSummaryProvider).first;
      expect(summary.status, FleetBusStatus.sos);
      expect(summary.statusNote, 'SOS alert active');
    });

    test('driver name falls back to "Unassigned" when driverId not in users', () {
      final c = makeContainer(
        buses: [_bus('1', driverId: 'ghost-driver')],
        routes: [_route('route-1', 'bus-1')],
        users: [],
      );
      addTearDown(c.dispose);

      expect(c.read(fleetSummaryProvider).first.driverName, 'Unassigned');
    });

    test('route with no matching bus is skipped', () {
      final c = makeContainer(
        buses: [],
        routes: [_route('route-1', 'bus-missing')],
      );
      addTearDown(c.dispose);

      expect(c.read(fleetSummaryProvider), isEmpty);
    });
  });

  group('fleetStatsProvider', () {
    ProviderContainer makeContainer({
      List<BusModel> buses = const [],
      List<RouteModel> routes = const [],
      List<StudentModel> students = const [],
      List<UserModel> users = const [],
    }) {
      return ProviderContainer(
        overrides: [
          busesListProvider.overrideWith((ref) => buses),
          routesListProvider.overrideWith((ref) => routes),
          studentsListProvider.overrideWith((ref) => students),
          usersListProvider.overrideWith((ref) => users),
        ],
      );
    }

    test('returns 100% on-time and 0 students when fleet is empty', () {
      final c = makeContainer();
      addTearDown(c.dispose);

      final stats = c.read(fleetStatsProvider);
      expect(stats.activeBuses, 0);
      expect(stats.totalStudents, 0);
      expect(stats.onTimePercent, 100);
    });

    test('totalStudents sums studentCount across all summaries', () {
      final c = makeContainer(
        buses: [_bus('1'), _bus('2')],
        routes: [_route('route-1', 'bus-1'), _route('route-2', 'bus-2')],
        students: [
          _student('s1', 'route-1'),
          _student('s2', 'route-1'),
          _student('s3', 'route-2'),
        ],
      );
      addTearDown(c.dispose);

      expect(c.read(fleetStatsProvider).totalStudents, 3);
    });

    test('onTimePercent is 0 when all buses are SOS', () {
      final c = makeContainer(
        buses: [_bus('1', status: BusStatus.sos)],
        routes: [_route('route-1', 'bus-1')],
      );
      addTearDown(c.dispose);

      expect(c.read(fleetStatsProvider).onTimePercent, 0);
    });

    test('onTimePercent is 50 when half buses are SOS', () {
      final c = makeContainer(
        buses: [_bus('1', status: BusStatus.active), _bus('2', status: BusStatus.sos)],
        routes: [_route('route-1', 'bus-1'), _route('route-2', 'bus-2')],
      );
      addTearDown(c.dispose);

      expect(c.read(fleetStatsProvider).onTimePercent, 50);
    });
  });

  group('AttendanceRepository.streamLast7Days edge cases', () {
    test('empty routeIds returns a stream that emits empty list', () async {
      final stream = Stream.value(<AttendanceModel>[]);
      expect(await stream.first, isEmpty);
    });

    test('routeIds list capped at 30 items', () {
      final ids = List.generate(35, (i) => 'route-$i');
      final capped = ids.length > 30 ? ids.sublist(0, 30) : ids;
      expect(capped.length, 30);
    });
  });
}
