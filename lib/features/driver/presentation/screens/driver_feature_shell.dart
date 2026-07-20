import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/mock_driver_repository.dart';
import '../bloc/driver_route_bloc.dart';
import '../bloc/driver_route_event.dart';
import 'driver_map_screen.dart';
import 'student_attendance_screen.dart';
import 'todays_route_screen.dart';

class DriverFeatureShell extends StatelessWidget {
  const DriverFeatureShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverRouteBloc(
        repository: MockDriverRepository(),
      )..add(const LoadDriverRoute()),
      child: const _DriverFeatureScaffold(),
    );
  }
}

class _DriverFeatureScaffold extends StatelessWidget {
  const _DriverFeatureScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: IndexedStack(
          index: 0,
          children: [
            TodaysRouteScreen(),
            StudentAttendanceScreen(),
            DriverMapScreen(),
          ],
        ),
      ),
    );
  }
}
