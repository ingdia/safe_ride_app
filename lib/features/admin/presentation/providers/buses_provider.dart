import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../data/models/bus_model.dart';
import '../../data/repositories/buses_repository.dart';
import 'schools_provider.dart';

final busesRepositoryProvider = Provider<BusesRepository>((ref) {
  return BusesRepository(ref.watch(firestoreProvider));
});

class BusesController extends StreamNotifier<List<BusModel>> {
  @override
  Stream<List<BusModel>> build() async* {
    final school = await ref.watch(schoolProvider.future);
    yield* ref.read(busesRepositoryProvider).stream(school.schoolId);
  }

  Future<void> addBus(BusModel bus) async {
    await ref.read(busesRepositoryProvider).add(bus);
  }

  Future<void> updateBus(BusModel bus) async {
    await ref.read(busesRepositoryProvider).update(bus);
  }

  Future<void> deleteBus(String busId) async {
    await ref.read(busesRepositoryProvider).delete(busId);
  }

  Future<int> deleteStale() async {
    final school = await ref.read(schoolProvider.future);
    return ref.read(busesRepositoryProvider).deleteStale(school.schoolId);
  }
}

final busesProvider =
    StreamNotifierProvider<BusesController, List<BusModel>>(
  BusesController.new,
);

final busesListProvider = Provider<List<BusModel>>((ref) {
  return ref.watch(busesProvider).value ?? [];
});

final busesErrorProvider = Provider<String?>((ref) {
  final e = ref.watch(busesProvider).asError;
  if (e == null) return null;
  final err = e.error;
  if (err is FirebaseException) return err.message ?? 'Firestore error';
  return err.toString();
});

