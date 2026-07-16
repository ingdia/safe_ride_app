import '../models/route_model.dart';

class RoutesRepository {
  final List<RouteModel> _routes = [
    RouteModel(
      routeId: 'route-a',
      schoolId: 'school-1',
      busId: 'bus-12',
      name: 'Route A',
      stops: [
        RouteStop(name: 'Stop 1', lat: 40.0701, lng: -73.0901, order: 1),
        RouteStop(name: 'Stop 2', lat: 40.0702, lng: -73.0902, order: 2),
        RouteStop(name: 'Stop 3', lat: 40.0703, lng: -73.0903, order: 3),
        RouteStop(name: 'Stop 4', lat: 40.0704, lng: -73.0904, order: 4),
        RouteStop(name: 'Stop 5', lat: 40.0705, lng: -73.0905, order: 5),
        RouteStop(name: 'Stop 6', lat: 40.0706, lng: -73.0906, order: 6),
        RouteStop(name: 'Stop 7', lat: 40.0707, lng: -73.0907, order: 7),
        RouteStop(name: 'Stop 8', lat: 40.0708, lng: -73.0908, order: 8),
        RouteStop(name: 'Stop 9', lat: 40.0709, lng: -73.0909, order: 9),
        RouteStop(name: 'Stop 10', lat: 40.0710, lng: -73.0910, order: 10),
        RouteStop(name: 'Stop 11', lat: 40.0711, lng: -73.0911, order: 11),
        RouteStop(name: 'Stop 12', lat: 40.0712, lng: -73.0912, order: 12),
      ],
    ),
    RouteModel(
      routeId: 'route-b',
      schoolId: 'school-1',
      busId: 'bus-07',
      name: 'Route B',
      stops: [
        RouteStop(name: 'Stop 1', lat: 40.0701, lng: -73.0901, order: 1),
        RouteStop(name: 'Stop 2', lat: 40.0702, lng: -73.0902, order: 2),
        RouteStop(name: 'Stop 3', lat: 40.0703, lng: -73.0903, order: 3),
        RouteStop(name: 'Stop 4', lat: 40.0704, lng: -73.0904, order: 4),
        RouteStop(name: 'Stop 5', lat: 40.0705, lng: -73.0905, order: 5),
        RouteStop(name: 'Stop 6', lat: 40.0706, lng: -73.0906, order: 6),
        RouteStop(name: 'Stop 7', lat: 40.0707, lng: -73.0907, order: 7),
        RouteStop(name: 'Stop 8', lat: 40.0708, lng: -73.0908, order: 8),
        RouteStop(name: 'Stop 9', lat: 40.0709, lng: -73.0909, order: 9),
        RouteStop(name: 'Stop 10', lat: 40.0710, lng: -73.0910, order: 10),
      ],
    ),
    RouteModel(
      routeId: 'route-c',
      schoolId: 'school-1',
      busId: 'bus-15',
      name: 'Route C',
      stops: [
        RouteStop(name: 'Stop 1', lat: 40.0701, lng: -73.0901, order: 1),
        RouteStop(name: 'Stop 2', lat: 40.0702, lng: -73.0902, order: 2),
        RouteStop(name: 'Stop 3', lat: 40.0703, lng: -73.0903, order: 3),
        RouteStop(name: 'Stop 4', lat: 40.0704, lng: -73.0904, order: 4),
        RouteStop(name: 'Stop 5', lat: 40.0705, lng: -73.0905, order: 5),
        RouteStop(name: 'Stop 6', lat: 40.0706, lng: -73.0906, order: 6),
        RouteStop(name: 'Stop 7', lat: 40.0707, lng: -73.0907, order: 7),
        RouteStop(name: 'Stop 8', lat: 40.0708, lng: -73.0908, order: 8),
        RouteStop(name: 'Stop 9', lat: 40.0709, lng: -73.0909, order: 9),
        RouteStop(name: 'Stop 10', lat: 40.0710, lng: -73.0910, order: 10),
        RouteStop(name: 'Stop 11', lat: 40.0711, lng: -73.0911, order: 11),
        RouteStop(name: 'Stop 12', lat: 40.0712, lng: -73.0912, order: 12),
        RouteStop(name: 'Stop 13', lat: 40.0713, lng: -73.0913, order: 13),
        RouteStop(name: 'Stop 14', lat: 40.0714, lng: -73.0914, order: 14),
        RouteStop(name: 'Stop 15', lat: 40.0715, lng: -73.0915, order: 15),
      ],
    ),
    RouteModel(
      routeId: 'route-d',
      schoolId: 'school-1',
      busId: 'bus-03',
      name: 'Route D',
      stops: [
        RouteStop(name: 'Stop 1', lat: 40.0701, lng: -73.0901, order: 1),
        RouteStop(name: 'Stop 2', lat: 40.0702, lng: -73.0902, order: 2),
        RouteStop(name: 'Stop 3', lat: 40.0703, lng: -73.0903, order: 3),
        RouteStop(name: 'Stop 4', lat: 40.0704, lng: -73.0904, order: 4),
        RouteStop(name: 'Stop 5', lat: 40.0705, lng: -73.0905, order: 5),
        RouteStop(name: 'Stop 6', lat: 40.0706, lng: -73.0906, order: 6),
        RouteStop(name: 'Stop 7', lat: 40.0707, lng: -73.0907, order: 7),
        RouteStop(name: 'Stop 8', lat: 40.0708, lng: -73.0908, order: 8),
      ],
    ),
  ];

  List<RouteModel> getAll() => List.unmodifiable(_routes);

  void add(RouteModel route) {
    _routes.add(route);
  }

  void update(RouteModel route) {
    final index = _routes.indexWhere((r) => r.routeId == route.routeId);
    if (index != -1) {
      _routes[index] = route;
    }
  }

  void delete(String routeId) {
    _routes.removeWhere((r) => r.routeId == routeId);
  }
}
