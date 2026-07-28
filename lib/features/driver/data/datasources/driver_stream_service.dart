import 'package:cloud_firestore/cloud_firestore.dart';

/// Service that will expose real-time Firestore streams for the driver feature.
///
/// Logic will be added in subsequent commits on `feature/driver-streams`.
class DriverStreamService {
  DriverStreamService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
}
