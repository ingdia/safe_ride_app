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
        break;
      case ParentTripActionType.moved:
        await seed.moveBusToNextStop();
        break;
      case ParentTripActionType.delayed:
        await seed.markTripDelayed();
        break;
      case ParentTripActionType.completed:
        await seed.markTripCompleted();
        break;
      case ParentTripActionType.emergency:
        await seed.createEmergencyNotification();
        break;
    }

    _ref
      ..invalidate(parentLiveTripProvider)
      ..invalidate(parentLiveTripStreamProvider)
      ..invalidate(parentNotificationsProvider)
      ..invalidate(parentNotificationsStreamProvider);
  }
}
