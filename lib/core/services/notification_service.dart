import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'saferide_channel';
  static const _channelName = 'SafeRide Notifications';

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  int _nextId = 1;

  Future<void> initialize() async {
    if (kIsWeb) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      ),
    );

    await _plugin.initialize(settings);
  }

  Future<void> _show(String title, String body) async {
    if (kIsWeb) return;
    await _plugin.show(_nextId++, title, body, _details);
  }

  Future<void> showWelcomeNotification({
    required String title,
    required String body,
  }) => _show(title, body);

  Future<void> showStudentApproved(String studentName) =>
      _show('Student Approved 🎉', '$studentName has been approved by the school.');

  Future<void> showBusAssigned(String busNumber) =>
      _show('Bus Assigned 🚌', 'Your child has been assigned to $busNumber.');

  Future<void> showTripStarted(String driverName) =>
      _show('Trip Started 🚌', '$driverName has started the route.');

  Future<void> showBusApproaching() =>
      _show('Bus Approaching ⏱️', 'The bus is approximately 10 minutes away.');

  Future<void> showStudentBoarded(String studentName) =>
      _show('Boarded ✅', '$studentName has boarded the bus.');

  Future<void> showStudentDroppedOff(String studentName) =>
      _show('Dropped Off 🏠', '$studentName has been dropped off safely.');

  Future<void> showTripCompleted() =>
      _show('Trip Completed ✅', 'Today\'s school trip has been completed.');
}
