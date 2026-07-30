import 'package:cloud_firestore/cloud_firestore.dart';

enum BusStatus { active, idle, sos }

extension BusStatusX on BusStatus {
  String get value {
    switch (this) {
      case BusStatus.active:
        return 'active';
      case BusStatus.idle:
        return 'idle';
      case BusStatus.sos:
        return 'sos';
    }
  }

  static BusStatus fromString(String? s) {
    switch (s) {
      case 'active':
        return BusStatus.active;
      case 'sos':
        return BusStatus.sos;
      default:
        return BusStatus.idle;
    }
  }
}

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
      status: BusStatusX.fromString(data['status'] as String?),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'plate_number': plateNumber,
        'capacity': capacity,
        'driver_id': driverId,
        'school_id': schoolId,
        'status': status.value,
        'created_at': Timestamp.fromDate(createdAt),
      };

  BusModel copyWith({
    String? plateNumber,
    int? capacity,
    String? driverId,
    BusStatus? status,
  }) {
    return BusModel(
      busId: busId,
      plateNumber: plateNumber ?? this.plateNumber,
      capacity: capacity ?? this.capacity,
      driverId: driverId ?? this.driverId,
      schoolId: schoolId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
