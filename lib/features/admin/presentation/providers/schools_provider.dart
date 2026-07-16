import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/school_model.dart';

final schoolProvider = Provider<SchoolModel>((ref) {
  return const SchoolModel(
    schoolId: 'school-1',
    name: 'Oakwood Elementary',
    address: '123 Oakwood Ave',
    adminId: 'user-admin-1',
  );
});
