import 'package:cloud_firestore/cloud_firestore.dart';

class BusLocationEntity {
  const BusLocationEntity({
    required this.busId,
    required this.lat,
    required this.lng,
    this.updatedAt,
  });

  /// Document id in `busLocations` is always the bus's id.
  final String busId;
  final double lat;
  final double lng;
  final DateTime? updatedAt;

  factory BusLocationEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return BusLocationEntity(
      busId: doc.id,
      lat: (d['lat'] as num?)?.toDouble() ?? 0,
      lng: (d['lng'] as num?)?.toDouble() ?? 0,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toUpdateMap({required double lat, required double lng}) => {
        'lat': lat,
        'lng': lng,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
