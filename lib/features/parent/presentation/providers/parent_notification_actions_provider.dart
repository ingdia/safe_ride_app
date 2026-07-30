import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'parent_data_providers.dart';

final parentNotificationActionsProvider = Provider<ParentNotificationActions>((
  ref,
) {
  return ParentNotificationActions(ref);
});

class ParentNotificationActions {
  ParentNotificationActions(this._ref);

  final Ref _ref;

  Future<void> markAsRead(String notificationId) async {
    final repository = _ref.read(parentRepositoryProvider);

    await repository.markNotificationAsRead(notificationId);

    _ref
      ..invalidate(parentNotificationsProvider)
      ..invalidate(parentNotificationsStreamProvider);
  }

  Future<void> markAllAsRead() async {
    final repository = _ref.read(parentRepositoryProvider);

    await repository.markAllNotificationsAsRead();

    _ref
      ..invalidate(parentNotificationsProvider)
      ..invalidate(parentNotificationsStreamProvider);
  }
}
