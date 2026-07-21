import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AdminTab {
  dashboard,
  buses,
  users,
  emergency,
  settings,
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
      case AdminTab.buses:
        return 1;
      case AdminTab.users:
        return 2;
      case AdminTab.emergency:
        return 3;
      case AdminTab.settings:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case AdminTab.dashboard:
        return 'Dashboard';
      case AdminTab.buses:
        return 'Buses';
      case AdminTab.users:
        return 'Users';
      case AdminTab.emergency:
        return 'Emergency';
      case AdminTab.settings:
        return 'Settings';
    }
  }
}

AdminTab adminTabFromIndex(int index) {
  switch (index) {
    case 1:
      return AdminTab.buses;
    case 2:
      return AdminTab.users;
    case 3:
      return AdminTab.emergency;
    case 4:
      return AdminTab.settings;
    case 0:
    default:
      return AdminTab.dashboard;
  }
}
