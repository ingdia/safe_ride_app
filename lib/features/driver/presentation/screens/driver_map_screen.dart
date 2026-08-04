import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../../core/firebase/firebase_collections.dart';
import '../../domain/models/route_stop.dart';
import '../providers/driver_route_provider.dart';
import '../providers/driver_route_state.dart';
import '../widgets/offline_data_banner.dart';

/// -----------------------------------------------------------------------
/// DriverMapScreen
///
/// Matches the "Live Map" screen from the Figma prototype:
///   - Orange/amber header ("Live Map" / "Real-time bus tracking")
///   - Live map card (flutter_map + OpenStreetMap, showing route stops and
///     the driver's own broadcast position from busLocations/{busId})
///   - "Route Stops" list with numbered stop badges + status chips
///     (Completed / Current / Upcoming)
///
/// This widget is the SCREEN CONTENT ONLY — it's rendered inside the
/// driver's bottom-nav shell, which already provides navigation.
/// -----------------------------------------------------------------------

/// Live-streams the driver's own bus position from `busLocations/{busId}` —
/// the same doc [FirestoreDriverRepository.updateBusLocation] writes to
/// while a trip is active.
final _ownBusLocationProvider =
    StreamProvider.autoDispose.family<latlong.LatLng?, String>((ref, busId) {
  if (busId.isEmpty) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.busLocations)
      .doc(busId)
      .snapshots()
      .map((doc) {
    final data = doc.data();
    if (data == null || data['lat'] is! num || data['lng'] is! num) return null;
    return latlong.LatLng((data['lat'] as num).toDouble(), (data['lng'] as num).toDouble());
  });
});

class DriverMapScreen extends ConsumerStatefulWidget {
  const DriverMapScreen({super.key});

  @override
  ConsumerState<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends ConsumerState<DriverMapScreen> {
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
              child: ref.watch(driverRouteProvider).when(
                data: (value) {
                  if (value is DriverRouteLoading || value is DriverRouteInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (value is DriverRouteError) {
                    return Center(
                      child: Text(
                        'Unable to load route: ${value.message}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    );
                  }

                  final loadedState = value as DriverRouteLoaded;
                  final stops = loadedState.stops;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Landscape-safe: switch stop list to a scrollable column
                      // regardless of orientation so nothing overflows.
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          const SizedBox(height: 16),
                          if (loadedState.isOffline) ...[
                            const OfflineDataBanner(),
                            const SizedBox(height: 12),
                          ],
                          _buildMap(loadedState),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(
                    'Unable to load route: $error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
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

  Widget _buildMap(DriverRouteLoaded loadedState) {
    final stopsWithCoords =
        loadedState.stops.where((s) => s.lat != null && s.lng != null).toList();
    final ownLocationAsync =
        ref.watch(_ownBusLocationProvider(loadedState.busId ?? ''));

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 260,
        child: ownLocationAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => _mapFallback('Unable to load live position.'),
          data: (ownLocation) {
            if (stopsWithCoords.isEmpty && ownLocation == null) {
              return _mapFallback(
                loadedState.stops.isEmpty
                    ? 'No route assigned yet.'
                    : 'This route\'s stops don\'t have coordinates yet — '
                        'ask your school admin to set them.',
              );
            }

            final center = ownLocation ??
                latlong.LatLng(stopsWithCoords.first.lat!, stopsWithCoords.first.lng!);

            return FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safe_ride_app',
                ),
                MarkerLayer(
                  markers: [
                    for (final stop in stopsWithCoords)
                      Marker(
                        point: latlong.LatLng(stop.lat!, stop.lng!),
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.location_on,
                          color: _statusInfo(stop.status).badgeText,
                          size: 32,
                        ),
                      ),
                    if (ownLocation != null)
                      Marker(
                        point: ownLocation,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.directions_bus_filled,
                          color: _amberDark,
                          size: 32,
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _mapFallback(String message) {
    return Container(
      color: const Color(0xFFFCE8CF),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
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