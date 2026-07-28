import 'package:cloud_firestore/cloud_firestore.dart';

import 'driver_firestore_paths.dart';

/// Typed snapshot of a `routes/{routeId}` document.
///
/// Fields mirror the Firestore document shape used by [FirestoreDriverRepository].
class RouteDocument {
  const RouteDocument({
    required this.routeId,
    required this.busId,
    required this.name,
    required this.stops,
  });

  /// The Firestore document ID.
  final String routeId;

  /// The bus assigned to this route.
  final String busId;

  /// Human-readable route name.
  final String name;

  /// Raw stops list as stored in Firestore. Parsed into [RouteStop] models
  /// by [FirestoreDriverRepository.fetchRouteStops].
  final List<Map<String, dynamic>> stops;

  /// Maps a Firestore document snapshot to a [RouteDocument].
  factory RouteDocument.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final rawStops = data['stops'];
    return RouteDocument(
      routeId: snapshot.id,
      busId: (data['busId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      stops: (rawStops is List)
          ? rawStops.whereType<Map<String, dynamic>>().toList()
          : const [],
    );
  }
}

/// Service that exposes real-time Firestore streams for the driver feature.
class DriverStreamService {
  DriverStreamService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Returns a stream that emits a [RouteDocument] whenever the
  /// `routes/{routeId}` document changes in Firestore.
  ///
  /// The stream is backed by [DocumentReference.snapshots], so it:
  /// - emits immediately with the current server state (or cached data when
  ///   offline),
  /// - continues emitting on every subsequent write to the document, and
  /// - closes only when the returned [Stream] subscription is cancelled.
  ///
  /// Emits `null` when the document does not exist.
  Stream<RouteDocument?> routeStream(String routeId) {
    return _firestore
        .collection(DriverFirestorePaths.routes)
        .doc(routeId)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? RouteDocument.fromSnapshot(snapshot) : null);
  }
}
