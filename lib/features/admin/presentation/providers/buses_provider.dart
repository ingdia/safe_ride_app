import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bus_model.dart';
import '../../data/repositories/buses_repository.dart';

final busesRepositoryProvider = Provider<BusesRepository>((ref) {
  return BusesRepository();
});

/// Riverpod 3.x Notifier-based controller for the bus roster, mirroring
/// the Notifier pattern used by ParentNavigationController. Backed by
/// BusesRepository (mock in-memory data layer) so Fleet Overview can
/// add/edit/delete buses at runtime.
class BusesController extends Notifier<List<BusModel>> {
  @override
  List<BusModel> build() {
    return ref.watch(busesRepositoryProvider).getAll();
  }

  void addBus(BusModel bus) {
    ref.read(busesRepositoryProvider).add(bus);
    state = ref.read(busesRepositoryProvider).getAll();
  }

  void updateBus(BusModel bus) {
    ref.read(busesRepositoryProvider).update(bus);
    state = ref.read(busesRepositoryProvider).getAll();
  }

  void deleteBus(String busId) {
    ref.read(busesRepositoryProvider).delete(busId);
    state = ref.read(busesRepositoryProvider).getAll();
  }
}

final busesProvider = NotifierProvider<BusesController, List<BusModel>>(
  BusesController.new,
);
