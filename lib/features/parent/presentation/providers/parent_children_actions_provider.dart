import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_child_entity.dart';
import 'parent_data_providers.dart';

final parentChildrenActionsProvider = Provider<ParentChildrenActions>((ref) {
  return ParentChildrenActions(ref);
});

class ParentChildrenActions {
  ParentChildrenActions(this._ref);

  final Ref _ref;

  Future<void> addChild({
    required String fullName,
    required String grade,
    required String busNumber,
    required String pickupStop,
  }) async {
    final repository = _ref.read(parentRepositoryProvider);

    final child = ParentChildEntity(
      id: '',
      fullName: fullName,
      grade: grade,
      busNumber: busNumber,
      pickupStop: pickupStop,
    ).trimmed();

    await repository.addChild(child);

    _ref.invalidate(parentChildrenStreamProvider);
  }

  Future<void> updateChild(ParentChildEntity child) async {
    final repository = _ref.read(parentRepositoryProvider);

    await repository.updateChild(child.trimmed());

    _ref.invalidate(parentChildrenStreamProvider);
  }

  Future<void> deleteChild(String childId) async {
    final repository = _ref.read(parentRepositoryProvider);

    await repository.deleteChild(childId);

    _ref.invalidate(parentChildrenStreamProvider);
  }
}
