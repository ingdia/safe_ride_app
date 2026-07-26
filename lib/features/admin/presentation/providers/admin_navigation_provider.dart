import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AdminTab {
  dashboard,
  emergency,
  map,
  alerts,
  profile,
}

final adminNavigationProvider =
    NotifierProvider<AdminNavigationController, AdminTab>(
      AdminNavigationController.new,
    );

class AdminNavigationController extends Notifier<AdminTab> {
  @override
  AdminTab build() {
    return AdminTab.dashboard;
  }

  void selectTab(AdminTab tab) {
    state = tab;
  }
}

extension AdminTabExtension on AdminTab {
  int get index {
    switch (this) {
      case AdminTab.dashboard:
        return 0;
      case AdminTab.emergency:
        return 1;
      case AdminTab.map:
        return 2;
      case AdminTab.alerts:
        return 3;
      case AdminTab.profile:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case AdminTab.dashboard:
        return 'Dashboard';
      case AdminTab.emergency:
        return 'Emergency';
      case AdminTab.map:
        return 'Map';
      case AdminTab.alerts:
        return 'Alerts';
      case AdminTab.profile:
        return 'Profile';
    }
  }
}

AdminTab adminTabFromIndex(int index) {
  switch (index) {
    case 1:
      return AdminTab.emergency;
    case 2:
      return AdminTab.map;
    case 3:
      return AdminTab.alerts;
    case 4:
      return AdminTab.profile;
    case 0:
    default:
      return AdminTab.dashboard;
  }
}
