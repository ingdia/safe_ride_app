import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/route_model.dart';
import '../../data/repositories/routes_repository.dart';

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository();
});

class RoutesController extends Notifier<List<RouteModel>> {
  @override
  List<RouteModel> build() {
    return ref.watch(routesRepositoryProvider).getAll();
  }

  void addRoute(RouteModel route) {
    ref.read(routesRepositoryProvider).add(route);
    state = ref.read(routesRepositoryProvider).getAll();
  }

  void updateRoute(RouteModel route) {
    ref.read(routesRepositoryProvider).update(route);
    state = ref.read(routesRepositoryProvider).getAll();
  }

  void deleteRoute(String routeId) {
    ref.read(routesRepositoryProvider).delete(routeId);
    state = ref.read(routesRepositoryProvider).getAll();
  }
}

final routesProvider = NotifierProvider<RoutesController, List<RouteModel>>(
  RoutesController.new,
);
