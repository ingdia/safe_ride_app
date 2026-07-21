import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/network_banner.dart';
import 'driver_map_screen.dart';
import 'student_attendance_screen.dart';
import 'todays_route_screen.dart';

class DriverFeatureShell extends ConsumerWidget {
  const DriverFeatureShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _DriverFeatureScaffold();
  }
}

class _DriverFeatureScaffold extends StatelessWidget {
  const _DriverFeatureScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NetworkBanner(
        child: SafeArea(
          child: IndexedStack(
            index: 0,
            children: const [
              TodaysRouteScreen(),
              StudentAttendanceScreen(),
              DriverMapScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
