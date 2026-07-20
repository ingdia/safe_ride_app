import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AdminTab { home, map, alerts, profile }

final adminNavigationProvider =
    NotifierProvider<AdminNavigationController, AdminTab>(
      AdminNavigationController.new,
    );

class AdminNavigationController extends Notifier<AdminTab> {
  @override
  AdminTab build() {
    return AdminTab.home;
  }

  void selectTab(AdminTab tab) {
    state = tab;
  }
}

extension AdminTabExtension on AdminTab {
  int get index {
    switch (this) {
      case AdminTab.home:
        return 0;
      case AdminTab.map:
        return 1;
      case AdminTab.alerts:
        return 2;
      case AdminTab.profile:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case AdminTab.home:
        return 'Home';
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
      return AdminTab.map;
    case 2:
      return AdminTab.alerts;
    case 3:
      return AdminTab.profile;
    case 0:
    default:
      return AdminTab.home;
  }
}
