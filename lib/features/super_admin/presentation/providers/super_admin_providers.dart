import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/data/models/school_model.dart';
import '../../../admin/data/models/user_model.dart';
import '../../data/repositories/super_admin_repository.dart';

final superAdminRepositoryProvider = Provider<SuperAdminRepository>((ref) {
  return SuperAdminRepository();
});

final allSchoolsProvider = StreamProvider<List<SchoolModel>>((ref) {
  return ref.watch(superAdminRepositoryProvider).watchSchools();
});

final schoolAdminsProvider = StreamProvider.family<List<UserModel>, String>((ref, schoolId) {
  return ref.watch(superAdminRepositoryProvider).watchAdmins(schoolId);
});
