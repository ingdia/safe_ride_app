import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  final String busId;
  final String plateNumber;
  final int capacity;
  final String driverId;
  final String schoolId;

  const BusModel({
    required this.busId,
    required this.plateNumber,
    required this.capacity,
    required this.driverId,
    required this.schoolId,
  });

  factory BusModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return BusModel(
      busId: doc.id,
      plateNumber: d['plateNumber'] as String? ?? '',
      capacity: (d['capacity'] as num?)?.toInt() ?? 0,
      driverId: d['driverId'] as String? ?? '',
      schoolId: d['schoolId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'plateNumber': plateNumber,
        'capacity': capacity,
        'driverId': driverId,
        'schoolId': schoolId,
      };
}
