import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../data/models/route_model.dart';
import '../../data/repositories/routes_repository.dart';
import 'schools_provider.dart';

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository(ref.watch(firestoreProvider));
});

class RoutesController extends StreamNotifier<List<RouteModel>> {
  @override
  Stream<List<RouteModel>> build() async* {
    final school = await ref.watch(schoolProvider.future);
    yield* ref.read(routesRepositoryProvider).stream(school.schoolId);
  }

  Future<void> addRoute(RouteModel route) async {
    await ref.read(routesRepositoryProvider).add(route);
  }

  Future<void> updateRoute(RouteModel route) async {
    await ref.read(routesRepositoryProvider).update(route);
  }

  Future<void> deleteRoute(String routeId) async {
    await ref.read(routesRepositoryProvider).delete(routeId);
  }

  Future<int> deleteStale() async {
    final school = await ref.read(schoolProvider.future);
    return ref.read(routesRepositoryProvider).deleteStale(school.schoolId);
  }
}

final routesProvider =
    StreamNotifierProvider<RoutesController, List<RouteModel>>(
  RoutesController.new,
);

final routesListProvider = Provider<List<RouteModel>>((ref) {
  return ref.watch(routesProvider).value ?? [];
});

final routesErrorProvider = Provider<String?>((ref) {
  final e = ref.watch(routesProvider).asError;
  if (e == null) return null;
  final err = e.error;
  if (err is FirebaseException) return err.message ?? 'Firestore error';
  return err.toString();
});
