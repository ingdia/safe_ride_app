import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ParentNotificationFilter { all, unread }

final parentNotificationFilterProvider =
    NotifierProvider<
      ParentNotificationFilterController,
      ParentNotificationFilter
    >(ParentNotificationFilterController.new);

class ParentNotificationFilterController
    extends Notifier<ParentNotificationFilter> {
  @override
  ParentNotificationFilter build() {
    return ParentNotificationFilter.all;
  }

  void selectFilter(ParentNotificationFilter filter) {
    state = filter;
  }
}
