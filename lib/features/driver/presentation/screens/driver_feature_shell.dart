import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/network_banner.dart';
import '../../../../shared/providers/attendance_cache_provider.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../data/repositories/mock_driver_repository.dart';
import '../bloc/driver_route_bloc.dart';
import '../bloc/driver_route_event.dart';
import 'driver_map_screen.dart';
import 'student_attendance_screen.dart';
import 'todays_route_screen.dart';

class DriverFeatureShell extends ConsumerWidget {
  const DriverFeatureShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider).maybeWhen(
          data: (v) => v,
          orElse: () => true,
        );
    final cacheService = ref.read(attendanceCacheProvider);

    return BlocProvider(
      create: (_) => DriverRouteBloc(
        repository: MockDriverRepository(),
        cacheService: cacheService,
        isOnline: isOnline,
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
