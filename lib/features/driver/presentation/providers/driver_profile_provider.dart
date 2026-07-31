import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';

class DriverProfile {
  const DriverProfile({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.busNumber,
    required this.route,
    required this.license,
  });

  final String name;
  final String role;
  final String email;
  final String phone;
  final String busNumber;
  final String route;
  final String license;
}

/// Live, real-data version of the driver's own profile — sourced from their
/// own `users/{uid}` doc plus whichever bus/route they're currently
/// assigned to. Re-emits automatically if an admin reassigns their bus
/// while the app is open.
final driverProfileProvider = StreamProvider<DriverProfile>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final email = FirebaseAuth.instance.currentUser?.email ?? '';
  if (uid == null) return Stream.value(_fallback(email));

  final firestore = FirebaseFirestore.instance;
  return firestore.collection(FirebaseCollections.users).doc(uid).snapshots().asyncMap((doc) async {
    final data = doc.data() ?? {};
    final busId = data['busId'] as String?;

    String busNumber = 'Unassigned';
    String routeName = 'No route assigned';

    if (busId != null && busId.isNotEmpty) {
      final busDoc = await firestore.collection(FirebaseCollections.buses).doc(busId).get();
      if (busDoc.exists) {
        busNumber = busDoc.data()?['plateNumber'] as String? ?? busId;
      }

      final routeQuery = await firestore
          .collection(FirebaseCollections.routes)
          .where('busId', isEqualTo: busId)
          .limit(1)
          .get();
      if (routeQuery.docs.isNotEmpty) {
        routeName = routeQuery.docs.first.data()['name'] as String? ?? routeName;
      }
    }

    return DriverProfile(
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? data['name'] as String
          : 'Driver',
      role: 'Driver',
      email: (data['email'] as String?) ?? email,
      phone: (data['phone'] as String?) ?? '',
      busNumber: busNumber,
      route: routeName,
      license: (data['licenseNumber'] as String?) ?? 'Not on file',
    );
  });
});

DriverProfile _fallback(String email) => DriverProfile(
      name: 'Driver',
      role: 'Driver',
      email: email,
      phone: '',
      busNumber: 'Unassigned',
      route: 'No route assigned',
      license: 'Not on file',
    );
