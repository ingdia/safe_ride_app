import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_child_entity.dart';
import 'parent_data_providers.dart';

final parentChildrenActionsProvider = Provider<ParentChildrenActions>((ref) {
  return ParentChildrenActions(ref);
});

class ParentChildrenActions {
  ParentChildrenActions(this._ref);

  final Ref _ref;

  /// Adds another child under the parent's existing school. The new student
  /// is created with status `pending`, matching first-time onboarding — an
  /// admin must approve and assign it before bus/route/stop info appears.
  Future<void> addChild({
    required String fullName,
    required String grade,
    required String schoolId,
    required String requestedStop,
  }) async {
    final repository = _ref.read(parentRepositoryProvider);

    await repository.addChild(
      fullName: fullName.trim(),
      grade: grade.trim(),
      schoolId: schoolId,
      requestedStop: requestedStop.trim(),
    );

    _ref.invalidate(parentChildrenStreamProvider);
  }

  Future<void> updateChild(ParentChildEntity child) async {
    final repository = _ref.read(parentRepositoryProvider);

    await repository.updateChild(child);

    _ref.invalidate(parentChildrenStreamProvider);
  }

  Future<void> deleteChild(String childId) async {
    final repository = _ref.read(parentRepositoryProvider);

    await repository.deleteChild(childId);

    _ref.invalidate(parentChildrenStreamProvider);
  }
}
