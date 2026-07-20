import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/driver_route_bloc.dart';
import '../bloc/driver_route_state.dart';
import '../../domain/models/route_stop.dart';

/// -----------------------------------------------------------------------
/// DriverMapScreen
///
/// Matches the "Live Map" screen from the Figma prototype:
///   - Orange/amber header ("Live Map" / "Real-time bus tracking")
///   - Live map card (placeholder until real map/GPS integration lands)
///   - "Route Stops" list with numbered stop badges + status chips
///     (Completed / Current / Upcoming)
///
/// This widget is the SCREEN CONTENT ONLY. It is meant to be wrapped
/// inside Diane's `BottomNavBarShell` (per Task 1 instructions) alongside
/// the "Today's Route" and "Student Attendance List" screens — do not add
/// a bottom nav bar here, the shell already provides it.
///
/// Data is currently mocked. In Task 2 (Driver BLoC & Mock Repositories),
/// replace `_stops` with state coming from the DriverBloc so this becomes
/// fully interactive.
/// -----------------------------------------------------------------------

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  // Brand palette (amber / white / gray) per Design Decisions section.
  static const Color _amber = Color(0xFFF5A623);
  static const Color _amberDark = Color(0xFFE8890C);
  static const Color _bgGray = Color(0xFFF7F7F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<DriverRouteBloc, DriverRouteState>(
                builder: (context, state) {
                  if (state is DriverRouteLoading || state is DriverRouteInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is DriverRouteError) {
                    return Center(
                      child: Text(
                        'Unable to load route: ${state.message}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    );
                  }

                  final loadedState = state as DriverRouteLoaded;
                  final stops = loadedState.stops;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Landscape-safe: switch stop list to a scrollable column
                      // regardless of orientation so nothing overflows.
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          const SizedBox(height: 16),
                          _buildMapPlaceholder(loadedState),
                          const SizedBox(height: 24),
                          _buildStopsHeader(stops),
                          const SizedBox(height: 12),
                          ...stops.map(_buildStopTile),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_amberDark, _amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Map',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white, // contrast ratio vs _amberDark exceeds 4.5:1
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Real-time bus tracking',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(DriverRouteLoaded loadedState) {
    // TODO: Swap for a real map widget (google_maps_flutter / flutter_map)
    // once live GPS coordinates are available from the BLoC layer.
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFFCE8CF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56, // meets Material min tap target (48dp+)
                decoration: const BoxDecoration(
                  color: _amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.navigation, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                'Interactive Map View',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                '${loadedState.routeProgress * 100 ~/ 1}% complete • ${loadedState.gpsStatus}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStopsHeader(List<RouteStop> stops) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Route Stops',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          '${stops.length} stops',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStopTile(RouteStop stop) {
    final info = _statusInfo(stop.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minHeight: 48), // Material tap size
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: info.borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: info.badgeBg, shape: BoxShape.circle),
            child: Text(
              '${stop.order}',
              style: TextStyle(fontWeight: FontWeight.bold, color: info.badgeText),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${stop.studentCount} student${stop.studentCount == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: info.chipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              info.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: info.chipText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(RouteStopStatus status) {
    switch (status) {
      case RouteStopStatus.completed:
        return _StatusInfo(
          label: 'Completed',
          borderColor: const Color(0xFFBFE6C6),
          badgeBg: const Color(0xFFDFF3E1),
          badgeText: const Color(0xFF2E7D32),
          chipBg: const Color(0xFFE3F6E5),
          chipText: const Color(0xFF2E7D32),
        );
      case RouteStopStatus.current:
        return _StatusInfo(
          label: 'Current',
          borderColor: _amber,
          badgeBg: const Color(0xFFFCE8CF),
          badgeText: _amberDark,
          chipBg: const Color(0xFFFCE8CF),
          chipText: _amberDark,
        );
      case RouteStopStatus.upcoming:
        return _StatusInfo(
          label: 'Upcoming',
          borderColor: const Color(0xFFE0E0E0),
          badgeBg: const Color(0xFFF0F0F0),
          badgeText: Colors.grey[700]!,
          chipBg: const Color(0xFFF0F0F0),
          chipText: Colors.grey[700]!,
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color borderColor;
  final Color badgeBg;
  final Color badgeText;
  final Color chipBg;
  final Color chipText;

  _StatusInfo({
    required this.label,
    required this.borderColor,
    required this.badgeBg,
    required this.badgeText,
    required this.chipBg,
    required this.chipText,
  });
}