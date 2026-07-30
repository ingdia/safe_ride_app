import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final driverProfileProvider = Provider<DriverProfile>((ref) {
  return const DriverProfile(
    name: 'Diana Ingabire',
    role: 'Driver',
    email: 'd.ingabire2@alustudent.com',
    phone: '+250 788 123 456',
    busNumber: 'Bus #12',
    route: 'North Loop Route',
    license: 'DL-2048 / Exp 06/2028',
  );
});
