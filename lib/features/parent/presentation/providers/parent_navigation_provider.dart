import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ParentTab { home, tracking, notifications, profile }

final parentNavigationProvider =
    NotifierProvider<ParentNavigationController, ParentTab>(
      ParentNavigationController.new,
    );

class ParentNavigationController extends Notifier<ParentTab> {
  @override
  ParentTab build() {
    return ParentTab.home;
  }

  void selectTab(ParentTab tab) {
    state = tab;
  }
}

extension ParentTabExtension on ParentTab {
  int get index {
    switch (this) {
      case ParentTab.home:
        return 0;
      case ParentTab.tracking:
        return 1;
      case ParentTab.notifications:
        return 2;
      case ParentTab.profile:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case ParentTab.home:
        return 'Home';
      case ParentTab.tracking:
        return 'Tracking';
      case ParentTab.notifications:
        return 'Alerts';
      case ParentTab.profile:
        return 'Profile';
    }
  }
}

ParentTab parentTabFromIndex(int index) {
  switch (index) {
    case 1:
      return ParentTab.tracking;
    case 2:
      return ParentTab.notifications;
    case 3:
      return ParentTab.profile;
    case 0:
    default:
      return ParentTab.home;
  }
}
