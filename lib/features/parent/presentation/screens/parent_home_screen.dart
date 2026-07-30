import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import '../providers/parent_data_providers.dart';
import '../widgets/parent_bus_status_card.dart';
import '../widgets/parent_ui_constants.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(parentLiveTripStreamProvider);
    final notificationsState = ref.watch(parentNotificationsStreamProvider);

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: tripState.when(
          loading: () {
            return _HomeContent(
              trip: _fallbackTrip('Loading live data...'),
              notificationsState: notificationsState,
            );
          },
          error: (error, stackTrace) {
            return _HomeContent(
              trip: _fallbackTrip('Using offline fallback'),
              notificationsState: notificationsState,
            );
          },
          data: (trip) {
            return _HomeContent(
              trip: trip,
              notificationsState: notificationsState,
            );
          },
        ),
      ),
    );
  }

  ParentTripEntity _fallbackTrip(String label) {
    return ParentTripEntity(
      tripId: 'trip_001',
      childName: 'Ineza Uwase',
      schoolName: 'Kigali Parents School',
      grade: 'Primary 4',
      busNumber: 'Bus #12',
      driverName: 'Jean Bosco',
      currentStop: 'Remera',
      nextStop: 'Giporoso',
      eta: '8:15 AM',
      stopsAway: 4,
      progress: 0.42,
      status: ParentTripStatus.onTime,
      busLatitude: -1.9565,
      busLongitude: 30.1044,
      lastUpdatedLabel: label,
      routeStops: const [
        ParentRouteStopEntity(
          id: 'stop_001',
          name: 'Kacyiru',
          time: '3 students',
          status: ParentRouteStopStatus.completed,
          position: 1,
        ),
        ParentRouteStopEntity(
          id: 'stop_002',
          name: 'Gishushu',
          time: '2 students',
          status: ParentRouteStopStatus.completed,
          position: 2,
        ),
        ParentRouteStopEntity(
          id: 'stop_003',
          name: 'Remera',
          time: '4 students',
          status: ParentRouteStopStatus.current,
          position: 3,
        ),
        ParentRouteStopEntity(
          id: 'stop_004',
          name: 'Giporoso',
          time: '2 students',
          status: ParentRouteStopStatus.upcoming,
          position: 4,
        ),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.trip, required this.notificationsState});

  final ParentTripEntity trip;
  final AsyncValue<List<ParentNotificationEntity>> notificationsState;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHeader(trip: trip),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ParentBusStatusCard(trip: trip),
          ),
          const SizedBox(height: 18),
          _ActionButtons(trip: trip),
          const SizedBox(height: 18),
          _RecentNotificationsCard(notificationsState: notificationsState),
          const SizedBox(height: 18),
          _StudentInfoCard(trip: trip),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: ParentUiColors.orange,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track ${trip.childName} in real time',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    trip.lastUpdatedLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              _showBusLocationDialog(context, trip);
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('View Live Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ParentUiColors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              _showDriverContactDialog(context, trip);
            },
            icon: const Icon(Icons.call_outlined),
            label: const Text('Contact Driver'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ParentUiColors.orange,
              side: const BorderSide(color: ParentUiColors.orange),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBusLocationDialog(BuildContext context, ParentTripEntity trip) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${trip.busNumber} Live Location'),
          content: Text(
            'Current stop: ${trip.currentStop}\n'
            'Next stop: ${trip.nextStop}\n'
            'Latitude: ${trip.busLatitude.toStringAsFixed(4)}\n'
            'Longitude: ${trip.busLongitude.toStringAsFixed(4)}\n'
            '${trip.lastUpdatedLabel}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDriverContactDialog(BuildContext context, ParentTripEntity trip) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Driver Contact'),
          content: Text(
            'Driver: ${trip.driverName}\n'
            'Bus: ${trip.busNumber}\n'
            'Route: ${trip.currentStop} to ${trip.nextStop}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _RecentNotificationsCard extends StatelessWidget {
  const _RecentNotificationsCard({required this.notificationsState});

  final AsyncValue<List<ParentNotificationEntity>> notificationsState;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          notificationsState.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: LinearProgressIndicator(),
            ),
            error: (error, stackTrace) => Text(
              'Unable to load notifications.',
              style: TextStyle(color: Colors.red.shade700),
            ),
            data: (notifications) {
              final recentNotifications = notifications.take(3).toList();

              if (recentNotifications.isEmpty) {
                return const Text('No notifications yet.');
              }

              return Column(
                children: [
                  for (final notification in recentNotifications)
                    _NotificationPreview(notification: notification),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview({required this.notification});

  final ParentNotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.grey.shade50
            : ParentUiColors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            notification.isRead
                ? Icons.notifications_none
                : Icons.notifications_active,
            color: ParentUiColors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            notification.time,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentInfoCard extends StatelessWidget {
  const _StudentInfoCard({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _InfoRow(title: 'Student', value: trip.childName),
          _InfoRow(title: 'School', value: trip.schoolName),
          _InfoRow(title: 'Grade', value: trip.grade),
          _InfoRow(title: 'Bus', value: trip.busNumber),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, required this.margin});

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
