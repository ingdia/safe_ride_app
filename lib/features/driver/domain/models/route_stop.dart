/// A single stop on a driver's route.
///
/// This is a plain data model for now. In Task 2, instances will come
/// from `DriverRepository` (mocked) via `DriverRouteBloc` instead of the
/// static list in [TodaysRouteScreen].
class RouteStop {
  const RouteStop({
    required this.order,
    required this.name,
    required this.studentCount,
    required this.time,
    this.isDestination = false,
  });

  final int order;
  final String name;
  final int studentCount;
  final String time;
  final bool isDestination;
}