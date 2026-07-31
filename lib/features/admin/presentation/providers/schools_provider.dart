import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/school_model.dart';
import 'admin_session_provider.dart';

/// Only ever watched from inside the admin shell, which gates rendering
/// until [adminSessionProvider] has data.
final schoolProvider = Provider<SchoolModel>((ref) {
  return ref.watch(adminSessionProvider).maybeWhen(
        data: (session) => session.school,
        orElse: () => throw StateError('Admin session not ready yet.'),
      );
});
