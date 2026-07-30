import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/students_repository.dart';
import 'schools_provider.dart';

final studentsRepositoryProvider = Provider<StudentsRepository>((ref) {
  return StudentsRepository(ref.watch(firestoreProvider));
});

final studentsProvider = StreamProvider<List<StudentModel>>((ref) async* {
  final school = await ref.watch(schoolProvider.future);
  yield* ref.read(studentsRepositoryProvider).stream(school.schoolId);
});

final studentsListProvider = Provider<List<StudentModel>>((ref) {
  return ref.watch(studentsProvider).value ?? [];
});
