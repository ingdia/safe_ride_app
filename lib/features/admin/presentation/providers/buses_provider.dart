import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bus_model.dart';
import '../../data/repositories/buses_repository.dart';
import 'admin_session_provider.dart';

final busesRepositoryProvider = Provider<BusesRepository>((ref) {
  return BusesRepository();
});

class BusesController extends Notifier<List<BusModel>> {
  StreamSubscription<List<BusModel>>? _subscription;

  @override
  List<BusModel> build() {
    final schoolId = ref.watch(adminSchoolIdProvider);
    final repository = ref.watch(busesRepositoryProvider);

    _subscription?.cancel();
    _subscription = repository.watch(schoolId).listen((buses) {
      state = buses;
    });
    ref.onDispose(() => _subscription?.cancel());

    return const [];
  }

  Future<void> addBus(BusModel bus) {
    return ref.read(busesRepositoryProvider).add(bus);
  }

  Future<void> updateBus(BusModel bus) {
    return ref.read(busesRepositoryProvider).update(bus);
  }

  Future<void> deleteBus(String busId) {
    return ref.read(busesRepositoryProvider).delete(busId);
  }
}

final busesProvider = NotifierProvider<BusesController, List<BusModel>>(
  BusesController.new,
);
