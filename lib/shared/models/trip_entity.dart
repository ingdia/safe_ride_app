import 'package:cloud_firestore/cloud_firestore.dart';

enum TripType { morning, afternoon }

enum TripStatus { scheduled, inProgress, completed }

class TripEntity {
  const TripEntity({
    required this.id,
    required this.routeId,
    required this.busId,
    required this.driverId,
    required this.schoolId,
    required this.type,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.studentEvents = const {},
    this.stopsCompleted = const [],
  });

  final String id;
  final String routeId;
  final String busId;
  final String driverId;
  final String schoolId;
  final TripType type;
  final TripStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// Map of studentId → event ('boarded' | 'droppedOff')
  final Map<String, String> studentEvents;

  /// Stop names the driver has explicitly marked as passed on this trip —
  /// distinct from GPS proximity, which is only a rough live estimate.
  final List<String> stopsCompleted;

  factory TripEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final eventsRaw = d['studentEvents'] as Map<String, dynamic>? ?? {};
    final stopsRaw = d['stopsCompleted'] as List<dynamic>? ?? [];
    return TripEntity(
      id: doc.id,
      routeId: d['routeId'] as String? ?? '',
      busId: d['busId'] as String? ?? '',
      driverId: d['driverId'] as String? ?? '',
      schoolId: d['schoolId'] as String? ?? '',
      type: (d['type'] as String?) == 'afternoon' ? TripType.afternoon : TripType.morning,
      status: _statusFrom(d['status'] as String?),
      startedAt: (d['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
      studentEvents: eventsRaw.map((k, v) => MapEntry(k, v as String)),
      stopsCompleted: stopsRaw.map((e) => e as String).toList(),
    );
  }

  static TripStatus _statusFrom(String? v) {
    switch (v) {
      case 'inProgress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      default:
        return TripStatus.scheduled;
    }
  }
}
