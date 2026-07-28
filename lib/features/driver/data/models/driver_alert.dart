import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/driver_firestore_fields.dart';

/// An Admin-sent alert targeting drivers on a specific route.
///
/// Documents live at `routes/{routeId}/alerts/{alertId}` and are written by
/// the admin feature. The driver feature consumes them read-only via
/// [DriverStreamService.alertsStream].
class DriverAlert {
  const DriverAlert({
    required this.alertId,
    required this.routeId,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  final String alertId;
  final String routeId;
  final String title;
  final String message;

  /// Raw type string as stored in Firestore (e.g. `"general"`, `"sos"`).
  final String type;
  final DateTime timestamp;
  final bool isRead;

  /// Parses a Firestore document snapshot into a [DriverAlert].
  factory DriverAlert.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    final ts = data[DriverFirestoreFields.timestamp];
    return DriverAlert(
      alertId: snapshot.id,
      routeId: (data[DriverFirestoreFields.routeId] as String?) ?? '',
      title: (data[DriverFirestoreFields.alertTitle] as String?) ?? '',
      message: (data[DriverFirestoreFields.alertMessage] as String?) ?? '',
      type: (data[DriverFirestoreFields.alertType] as String?) ?? 'general',
      timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
      isRead: (data[DriverFirestoreFields.alertIsRead] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        DriverFirestoreFields.alertId: alertId,
        DriverFirestoreFields.routeId: routeId,
        DriverFirestoreFields.alertTitle: title,
        DriverFirestoreFields.alertMessage: message,
        DriverFirestoreFields.alertType: type,
        DriverFirestoreFields.timestamp: Timestamp.fromDate(timestamp),
        DriverFirestoreFields.alertIsRead: isRead,
      };
}
