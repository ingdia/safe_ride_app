import 'package:cloud_firestore/cloud_firestore.dart';

class BusEntity {
  const BusEntity({
    required this.id,
    required this.plateNumber,
    required this.capacity,
    required this.schoolId,
    this.driverId,
  });

  final String id;
  final String plateNumber;
  final int capacity;
  final String schoolId;
  final String? driverId;

  factory BusEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return BusEntity(
      id: doc.id,
      plateNumber: d['plateNumber'] as String? ?? '',
      capacity: (d['capacity'] as num?)?.toInt() ?? 0,
      schoolId: d['schoolId'] as String? ?? '',
      driverId: d['driverId'] as String?,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'plateNumber': plateNumber,
        'capacity': capacity,
        'schoolId': schoolId,
        'driverId': driverId,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
