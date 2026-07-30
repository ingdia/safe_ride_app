import 'package:cloud_firestore/cloud_firestore.dart';

class DriverAlert {
  const DriverAlert({
    required this.alertId,
    required this.routeId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
  });

  final String alertId;
  final String routeId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime timestamp;

  factory DriverAlert.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return DriverAlert(
      alertId: snapshot.id,
      routeId: data['routeId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      isRead: data['isRead'] as bool? ?? false,
      timestamp: _parseTimestamp(data['timestamp']),
    );
  }

  static DateTime _parseTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
