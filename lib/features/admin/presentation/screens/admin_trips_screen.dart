import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../shared/models/trip_entity.dart';
import '../providers/admin_session_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

final _schoolTripsProvider = StreamProvider.autoDispose<List<TripEntity>>((ref) {
  final schoolId = ref.watch(adminSchoolIdProvider);
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.trips)
      .where('schoolId', isEqualTo: schoolId)
      .orderBy('startedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(TripEntity.fromDoc).toList());
});

class AdminTripsScreen extends ConsumerWidget {
  const AdminTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(_schoolTripsProvider);

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: HeaderTitleBlock(
                  title: 'Trips',
                  subtitle: 'Active and completed trips',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            tripsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, st) => SliverToBoxAdapter(
                child: Padding(padding: const EdgeInsets.all(24), child: Text('Unable to load trips.\n$e')),
              ),
              data: (trips) {
                if (trips.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No trips have started yet.')),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(AdminUiSpacing.md),
                  sliver: SliverList.separated(
                    itemCount: trips.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AdminUiSpacing.sm),
                    itemBuilder: (context, index) => _TripCard(trip: trips[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});
  final TripEntity trip;

  @override
  Widget build(BuildContext context) {
    final isInProgress = trip.status == TripStatus.inProgress;
    final isCompleted = trip.status == TripStatus.completed;

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
            isInProgress ? Icons.directions_bus_filled : Icons.check_circle_outline,
            color: isInProgress ? AdminUiColors.primaryOrange : AdminUiColors.textSecondary,
          ),
          const SizedBox(width: AdminUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.type == TripType.morning ? 'Morning' : 'Afternoon'} trip',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  'Bus ${trip.busId} • ${trip.studentEvents.length} student events',
                  style: const TextStyle(color: AdminUiColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AdminUiColors.onTimeBg
                  : isInProgress
                      ? AdminUiColors.statCardBackground
                      : AdminUiColors.divider,
              borderRadius: BorderRadius.circular(AdminUiRadii.chip),
            ),
            child: Text(
              isCompleted ? 'Completed' : (isInProgress ? 'In Progress' : 'Scheduled'),
              style: TextStyle(
                color: isCompleted
                    ? AdminUiColors.onTimeFg
                    : isInProgress
                        ? AdminUiColors.primaryOrange
                        : AdminUiColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
