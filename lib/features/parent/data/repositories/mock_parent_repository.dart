import '../../domain/entities/parent_dashboard_entity.dart';
import '../../domain/entities/parent_notification_entity.dart';
import '../../domain/entities/parent_trip_entity.dart';
import 'parent_repository.dart';

class MockParentRepository implements ParentRepository {
  const MockParentRepository();

  @override
  Future<ParentDashboardEntity> getDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final notifications = await getNotifications();
    final trip = await getLiveTrip();

    return ParentDashboardEntity(
      parentName: 'Uwimana',
      childName: trip.childName,
      schoolName: trip.schoolName,
      grade: trip.grade,
      trip: trip,
      recentNotifications: notifications.take(3).toList(),
      unreadNotifications: notifications
          .where((notification) => !notification.isRead)
          .length,
      safeUpdates: notifications
          .where(
            (notification) =>
                notification.type == ParentAlertType.boarded ||
                notification.type == ParentAlertType.dropped,
          )
          .length,
      importantAlerts: notifications
          .where(
            (notification) =>
                notification.type == ParentAlertType.delay ||
                notification.type == ParentAlertType.emergency,
          )
          .length,
    );
  }

  @override
  Future<ParentTripEntity> getLiveTrip() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return const ParentTripEntity(
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
      routeStops: [
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
        ParentRouteStopEntity(
          id: 'stop_005',
          name: 'Kimironko',
          time: '3 students',
          status: ParentRouteStopStatus.upcoming,
          position: 5,
        ),
        ParentRouteStopEntity(
          id: 'stop_006',
          name: 'Kibagabaga',
          time: '2 students',
          status: ParentRouteStopStatus.upcoming,
          position: 6,
        ),
        ParentRouteStopEntity(
          id: 'stop_007',
          name: 'Kigali Parents School',
          time: 'School arrival',
          status: ParentRouteStopStatus.upcoming,
          position: 7,
        ),
      ],
    );
  }

  @override
  Future<List<ParentNotificationEntity>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const [
      ParentNotificationEntity(
        id: 'notification_001',
        title: 'Bus is 5 minutes away',
        message: 'Bus #12 is approaching Remera stop.',
        time: '2 min ago',
        type: ParentAlertType.general,
        isRead: false,
      ),
      ParentNotificationEntity(
        id: 'notification_002',
        title: 'Ineza checked in to Bus #12',
        message: 'Ineza Uwase safely checked in at Kacyiru.',
        time: '15 min ago',
        type: ParentAlertType.boarded,
        isRead: false,
      ),
      ParentNotificationEntity(
        id: 'notification_003',
        title: 'Route delay due to traffic',
        message: 'There is light traffic near Giporoso.',
        time: '1 hour ago',
        type: ParentAlertType.delay,
        isRead: false,
      ),
      ParentNotificationEntity(
        id: 'notification_004',
        title: 'Bus passed Gishushu',
        message: 'Bus #12 has already passed Gishushu safely.',
        time: '20 min ago',
        type: ParentAlertType.general,
        isRead: true,
      ),
      ParentNotificationEntity(
        id: 'notification_005',
        title: 'Trip completed yesterday',
        message: 'Ineza was safely dropped off after school.',
        time: 'Yesterday',
        type: ParentAlertType.dropped,
        isRead: true,
      ),
    ];
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
