import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AdminTab {
  buses,
  drivers,
  students,
  routes,
  profile,
}

final adminNavigationProvider =
    NotifierProvider<AdminNavigationController, AdminTab>(
      AdminNavigationController.new,
    );

class AdminNavigationController extends Notifier<AdminTab> {
  @override
  AdminTab build() {
    return AdminTab.buses;
  }

  void selectTab(AdminTab tab) {
    state = tab;
  }
}

extension AdminTabExtension on AdminTab {
  int get index {
    switch (this) {
      case AdminTab.buses:
        return 0;
      case AdminTab.drivers:
        return 1;
      case AdminTab.students:
        return 2;
      case AdminTab.routes:
        return 3;
      case AdminTab.profile:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case AdminTab.buses:
        return 'Buses';
      case AdminTab.drivers:
        return 'Drivers';
      case AdminTab.students:
        return 'Students';
      case AdminTab.routes:
        return 'Routes';
      case AdminTab.profile:
        return 'Profile';
    }
  }
}

AdminTab adminTabFromIndex(int index) {
  switch (index) {
    case 1:
      return AdminTab.drivers;
    case 2:
      return AdminTab.students;
    case 3:
      return AdminTab.routes;
    case 4:
      return AdminTab.profile;
    case 0:
    default:
      return AdminTab.buses;
  }
}
