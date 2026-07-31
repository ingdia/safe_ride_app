import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/parent_notification_entity.dart';
import '../datasources/parent_firestore_fields.dart';

class ParentNotificationFirestoreModel {
  const ParentNotificationFirestoreModel._();

  static ParentNotificationEntity fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    if (data == null) {
      return fallback(snapshot.id);
    }

    return ParentNotificationEntity(
      id: snapshot.id,
      title: _readString(
        data,
        ParentNotificationFields.title,
        'SafeRide Alert',
      ),
      message: _readString(
        data,
        ParentNotificationFields.message,
        'You have a new SafeRide notification.',
      ),
      time: _readTimeLabel(data[ParentNotificationFields.createdAt]),
      type: _typeFromString(
        _readString(data, ParentNotificationFields.type, 'general'),
      ),
      isRead: _readBool(data, ParentNotificationFields.isRead, false),
    );
  }

  static ParentNotificationEntity fallback(String notificationId) {
    return ParentNotificationEntity(
      id: notificationId,
      title: 'SafeRide Alert',
      message: 'You have a new SafeRide notification.',
      time: 'Just now',
      type: ParentAlertType.general,
      isRead: false,
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key,
    String fallbackValue,
  ) {
    final value = data[key];

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return fallbackValue;
  }

  static bool _readBool(
    Map<String, dynamic> data,
    String key,
    bool fallbackValue,
  ) {
    final value = data[key];

    if (value is bool) {
      return value;
    }

    return fallbackValue;
  }

  static String _readTimeLabel(Object? value) {
    if (value is Timestamp) {
      final createdAt = value.toDate();
      final difference = DateTime.now().difference(createdAt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      }

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      }

      if (difference.inHours < 24) {
        return '${difference.inHours} hr ago';
      }

      return '${difference.inDays} day ago';
    }

    return 'Just now';
  }

  static ParentAlertType _typeFromString(String type) {
    switch (type) {
      case 'boarded':
        return ParentAlertType.boarded;
      case 'dropped':
        return ParentAlertType.dropped;
      case 'delay':
        return ParentAlertType.delay;
      case 'emergency':
        return ParentAlertType.emergency;
      case 'general':
      default:
        return ParentAlertType.general;
    }
  }
}
