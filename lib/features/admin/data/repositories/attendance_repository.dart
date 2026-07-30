import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  AttendanceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirebaseCollections.attendance);

  Stream<List<AttendanceModel>> streamLast7Days(List<String> routeIds) {
    if (routeIds.isEmpty) return Stream.value([]);

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final cutoffDate =
        '${cutoff.year.toString().padLeft(4, '0')}-'
        '${cutoff.month.toString().padLeft(2, '0')}-'
        '${cutoff.day.toString().padLeft(2, '0')}';

    final ids = routeIds.length > 30 ? routeIds.sublist(0, 30) : routeIds;

    return _col
        .where('route_id', whereIn: ids)
        .where('date', isGreaterThanOrEqualTo: cutoffDate)
        .snapshots()
        .map((snap) => snap.docs.map(AttendanceModel.fromFirestore).toList());
  }
}
