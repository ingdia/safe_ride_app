import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../providers/users_provider.dart';

// ---------------------------------------------------------------------------
// Derived providers — no separate repository needed; drivers are users
// ---------------------------------------------------------------------------

final driversProvider = Provider<List<UserModel>>((ref) {
  return ref
      .watch(schoolUsersListProvider)
      .where((u) => u.role == UserRole.driver)
      .toList();
});

final pendingDriversProvider = Provider<List<UserModel>>((ref) {
  return ref
      .watch(driversProvider)
      .where((d) => d.approvalStatus == DriverApprovalStatus.pending)
      .toList();
});

final pendingDriversCountProvider = Provider<int>((ref) {
  return ref.watch(pendingDriversProvider).length;
});

// ---------------------------------------------------------------------------
// Approval actions — write directly to Firestore via UsersRepository
// ---------------------------------------------------------------------------

class DriversNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> approveDriver(String userId) async {
    await ref
        .read(usersRepositoryProvider)
        .updateApprovalStatus(userId, DriverApprovalStatus.approved);
  }

  Future<void> rejectDriver(String userId) async {
    await ref
        .read(usersRepositoryProvider)
        .updateApprovalStatus(userId, DriverApprovalStatus.rejected);
  }
}

final driversNotifierProvider = NotifierProvider<DriversNotifier, void>(
  DriversNotifier.new,
);
