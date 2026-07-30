import 'package:cloud_firestore/cloud_firestore.dart';

enum BusStatus { active, idle, sos }

const int kBusStaleThresholdDays = 30;

class BusModel {
  final String busId;
  final String plateNumber;
  final int capacity;
  final String driverId;
  final String schoolId;
  final BusStatus status;
  final DateTime createdAt;

  const BusModel({
    required this.busId,
    required this.plateNumber,
    required this.capacity,
    required this.driverId,
    required this.schoolId,
    this.status = BusStatus.idle,
    required this.createdAt,
  });

  factory BusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusModel(
      busId: doc.id,
      plateNumber: data['plate_number'] as String? ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      driverId: data['driver_id'] as String? ?? '',
      schoolId: data['school_id'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      createdAt:
          (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'plate_number': plateNumber,
        'capacity': capacity,
        'driver_id': driverId,
        'school_id': schoolId,
        'status': _statusValue(status),
        'created_at': Timestamp.fromDate(createdAt),
      };

  static BusStatus _statusFromString(String? s) {
    switch (s) {
      case 'active':
        return BusStatus.active;
      case 'sos':
        return BusStatus.sos;
      default:
        return BusStatus.idle;
    }
  }

  static String _statusValue(BusStatus s) {
    switch (s) {
      case BusStatus.active:
        return 'active';
      case BusStatus.sos:
        return 'sos';
      case BusStatus.idle:
        return 'idle';
    }
  }
}
