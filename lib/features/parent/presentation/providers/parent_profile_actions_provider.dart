import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_profile_entity.dart';
import 'parent_data_providers.dart';

final parentProfileActionsProvider = Provider<ParentProfileActions>((ref) {
  return ParentProfileActions(ref);
});

class ParentProfileActions {
  ParentProfileActions(this._ref);

  final Ref _ref;

  Future<void> updateProfile(ParentProfileEntity profile) async {
    final repository = _ref.read(parentRepositoryProvider);

    await repository.updateParentProfile(profile.trimmed());

    _ref
      ..invalidate(parentProfileProvider)
      ..invalidate(parentProfileStreamProvider);
  }
}
