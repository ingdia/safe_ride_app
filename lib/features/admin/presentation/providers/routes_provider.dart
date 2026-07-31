import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/route_model.dart';
import '../../data/repositories/routes_repository.dart';
import 'admin_session_provider.dart';

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository();
});

class RoutesController extends Notifier<List<RouteModel>> {
  StreamSubscription<List<RouteModel>>? _subscription;

  @override
  List<RouteModel> build() {
    final schoolId = ref.watch(adminSchoolIdProvider);
    final repository = ref.watch(routesRepositoryProvider);

    _subscription?.cancel();
    _subscription = repository.watch(schoolId).listen((routes) {
      state = routes;
    });
    ref.onDispose(() => _subscription?.cancel());

    return const [];
  }

  Future<void> addRoute(RouteModel route) {
    return ref.read(routesRepositoryProvider).add(route);
  }

  Future<void> updateRoute(RouteModel route) {
    return ref.read(routesRepositoryProvider).update(route);
  }

  Future<void> deleteRoute(String routeId) {
    return ref.read(routesRepositoryProvider).delete(routeId);
  }
}

final routesProvider = NotifierProvider<RoutesController, List<RouteModel>>(
  RoutesController.new,
);
