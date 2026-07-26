import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_trip_action_type.dart';
import 'parent_data_providers.dart';

final parentTripNotificationActionsProvider =
    Provider<ParentTripNotificationActions>((ref) {
      return ParentTripNotificationActions(ref);
    });

class ParentTripNotificationActions {
  ParentTripNotificationActions(this._ref);

  final Ref _ref;

  Future<void> runTripAction(ParentTripActionType actionType) async {
    final seed = _ref.read(parentDemoTripSeedProvider);

    switch (actionType) {
      case ParentTripActionType.boarded:
        await seed.saveDemoTrip();
      case ParentTripActionType.moved:
        await seed.moveBusToNextStop();
      case ParentTripActionType.delayed:
        await seed.markTripDelayed();
      case ParentTripActionType.completed:
        await seed.markTripCompleted();
    }

    _ref
      ..invalidate(parentLiveTripProvider)
      ..invalidate(parentLiveTripStreamProvider)
      ..invalidate(parentNotificationsProvider)
      ..invalidate(parentNotificationsStreamProvider);
  }
}
