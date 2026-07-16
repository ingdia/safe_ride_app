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
      parentName: 'Parent',
      childName: trip.childName,
      schoolName: trip.schoolName,
      grade: trip.grade,
      trip: trip,
      recentNotifications: notifications.take(2).toList(),
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
      childName: 'Ineza Juliette',
      schoolName: 'Kigali Parents School',
      grade: 'Primary 4',
      busNumber: 'Bus KGL 204',
      driverName: 'Emmanuel Ndayisaba',
      currentStop: 'Kacyiru',
      nextStop: 'Kimironko',
      eta: '12 min',
      stopsAway: 2,
      progress: 0.64,
      status: ParentTripStatus.onTime,
      routeStops: [
        ParentRouteStopEntity(
          id: 'stop_001',
          name: 'Kacyiru pickup point',
          time: '07:10',
          status: ParentRouteStopStatus.completed,
          position: 1,
        ),
        ParentRouteStopEntity(
          id: 'stop_002',
          name: 'Kimironko main road',
          time: '07:25',
          status: ParentRouteStopStatus.current,
          position: 2,
        ),
        ParentRouteStopEntity(
          id: 'stop_003',
          name: 'School gate',
          time: '07:45',
          status: ParentRouteStopStatus.upcoming,
          position: 3,
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
        title: 'Child boarded',
        message: 'Ineza boarded Bus KGL 204 at Kacyiru pickup point.',
        time: '7:10 AM',
        type: ParentAlertType.boarded,
        isRead: false,
      ),
      ParentNotificationEntity(
        id: 'notification_002',
        title: 'Bus delay',
        message:
            'Bus KGL 204 is delayed by 5 minutes due to traffic near Kimironko.',
        time: '7:22 AM',
        type: ParentAlertType.delay,
        isRead: false,
      ),
      ParentNotificationEntity(
        id: 'notification_003',
        title: 'Bus is moving',
        message: 'The bus is currently heading to the school gate.',
        time: '7:30 AM',
        type: ParentAlertType.general,
        isRead: true,
      ),
      ParentNotificationEntity(
        id: 'notification_004',
        title: 'Child dropped off',
        message: 'Ineza was safely dropped off at Kacyiru pickup point.',
        time: '4:18 PM',
        type: ParentAlertType.dropped,
        isRead: true,
      ),
      ParentNotificationEntity(
        id: 'notification_005',
        title: 'Trip completed',
        message: 'The afternoon trip was completed successfully.',
        time: '4:25 PM',
        type: ParentAlertType.general,
        isRead: true,
      ),
    ];
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
