import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/driver_model.dart';
import '../../data/repositories/drivers_repository.dart';

final driversRepositoryProvider = Provider((ref) => DriversRepository());

final driversProvider = NotifierProvider<DriversNotifier, List<DriverModel>>(
  DriversNotifier.new,
);

class DriversNotifier extends Notifier<List<DriverModel>> {
  @override
  List<DriverModel> build() {
    return ref.read(driversRepositoryProvider).fetchDrivers();
  }

  void approveDriver(String driverId) {
    ref
        .read(driversRepositoryProvider)
        .updateStatus(driverId, DriverApprovalStatus.approved);
    state = ref.read(driversRepositoryProvider).fetchDrivers();
  }

  void rejectDriver(String driverId) {
    ref
        .read(driversRepositoryProvider)
        .updateStatus(driverId, DriverApprovalStatus.rejected);
    state = ref.read(driversRepositoryProvider).fetchDrivers();
  }
}

final pendingDriversProvider = Provider<List<DriverModel>>((ref) {
  return ref
      .watch(driversProvider)
      .where((d) => d.status == DriverApprovalStatus.pending)
      .toList();
});

final pendingDriversCountProvider = Provider<int>((ref) {
  return ref.watch(pendingDriversProvider).length;
});
