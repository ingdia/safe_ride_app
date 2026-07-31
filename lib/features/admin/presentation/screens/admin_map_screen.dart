import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../shared/models/bus_location_entity.dart';
import '../providers/buses_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

final _schoolBusLocationsProvider = StreamProvider.autoDispose.family<
    List<BusLocationEntity>, List<String>>((ref, busIds) {
  if (busIds.isEmpty) return Stream.value(const []);
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.busLocations)
      .where(FieldPath.documentId, whereIn: busIds.length > 10 ? busIds.sublist(0, 10) : busIds)
      .snapshots()
      .map((snap) => snap.docs.map(BusLocationEntity.fromDoc).toList());
});

class LiveMapScreen extends ConsumerWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buses = ref.watch(busesProvider);
    final busIds = buses.map((b) => b.busId).toList();
    final locationsAsync = ref.watch(_schoolBusLocationsProvider(busIds));

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: HeaderTitleBlock(
                  title: 'Live Map',
                  subtitle: 'Real-time bus tracking',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AdminUiRadii.card),
                  child: SizedBox(
                    height: 320,
                    child: locationsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Unable to load bus locations.\n$e')),
                      data: (locations) => _MapView(locations: locations),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.sm,
                AdminUiSpacing.md,
                0,
              ),
              sliver: const SliverToBoxAdapter(
                child: Text('Buses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: locationsAsync.maybeWhen(
                data: (locations) => buses.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('No buses added yet.')),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: buses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AdminUiSpacing.sm),
                        itemBuilder: (context, index) {
                          final bus = buses[index];
                          final loc = locations.where((l) => l.busId == bus.busId).toList();
                          return _BusLocationRow(
                            plateNumber: bus.plateNumber,
                            hasLocation: loc.isNotEmpty,
                            updatedAt: loc.isNotEmpty ? loc.first.updatedAt : null,
                          );
                        },
                      ),
                orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.locations});

  final List<BusLocationEntity> locations;

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return Container(
        color: AdminUiColors.statCardBackground,
        alignment: Alignment.center,
        child: const Text(
          'No buses are broadcasting a live location right now.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AdminUiColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      );
    }

    final center = latlong.LatLng(locations.first.lat, locations.first.lng);

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 12),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.saferide.app',
        ),
        MarkerLayer(
          markers: [
            for (final loc in locations)
              Marker(
                point: latlong.LatLng(loc.lat, loc.lng),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.directions_bus_filled,
                  color: AdminUiColors.primaryOrange,
                  size: 32,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BusLocationRow extends StatelessWidget {
  const _BusLocationRow({
    required this.plateNumber,
    required this.hasLocation,
    required this.updatedAt,
  });

  final String plateNumber;
  final bool hasLocation;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_bus_filled_rounded,
            color: hasLocation ? AdminUiColors.primaryOrange : AdminUiColors.textSecondary,
          ),
          const SizedBox(width: AdminUiSpacing.md),
          Expanded(
            child: Text('Bus $plateNumber', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(
            hasLocation ? 'Live' : 'No signal',
            style: TextStyle(
              color: hasLocation ? AdminUiColors.onTimeFg : AdminUiColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
