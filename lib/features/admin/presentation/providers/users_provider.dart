import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/drivers_repository.dart';
import 'admin_session_provider.dart';

final driversRepositoryProvider = Provider<DriversRepository>((ref) {
  return DriversRepository();
});

class DriversController extends Notifier<List<UserModel>> {
  StreamSubscription<List<UserModel>>? _subscription;

  @override
  List<UserModel> build() {
    final schoolId = ref.watch(adminSchoolIdProvider);
    final repository = ref.watch(driversRepositoryProvider);

    _subscription?.cancel();
    _subscription = repository.watchDrivers(schoolId).listen((drivers) {
      state = drivers;
    });
    ref.onDispose(() => _subscription?.cancel());

    return const [];
  }

  /// Returns the temporary password the admin should share with the driver
  /// (there's no email-delivery mechanism available on the Spark plan).
  Future<void> createDriver({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) {
    final schoolId = ref.read(adminSchoolIdProvider);
    return ref.read(driversRepositoryProvider).createDriver(
          name: name,
          email: email,
          password: password,
          phone: phone,
          schoolId: schoolId,
        );
  }

  Future<void> assignBus({required String driverUid, required String? busId}) {
    return ref.read(driversRepositoryProvider).assignBus(driverUid: driverUid, busId: busId);
  }
}

final driversProvider = NotifierProvider<DriversController, List<UserModel>>(
  DriversController.new,
);
