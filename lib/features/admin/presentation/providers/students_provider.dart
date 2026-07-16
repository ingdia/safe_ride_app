import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/student_model.dart';

final List<StudentModel> _seedStudents = [
  const StudentModel(
    studentId: 'student-1',
    name: 'Ava Martinez',
    grade: '3',
    schoolId: 'school-1',
    parentId: 'user-parent-1',
    routeId: 'route-a',
  ),
  const StudentModel(
    studentId: 'student-2',
    name: 'Noah Martinez',
    grade: '5',
    schoolId: 'school-1',
    parentId: 'user-parent-1',
    routeId: 'route-a',
  ),
  const StudentModel(
    studentId: 'student-3',
    name: 'Ethan Kim',
    grade: '2',
    schoolId: 'school-1',
    parentId: 'user-parent-2',
    routeId: 'route-b',
  ),
  const StudentModel(
    studentId: 'student-4',
    name: 'Mia Kim',
    grade: '4',
    schoolId: 'school-1',
    parentId: 'user-parent-2',
    routeId: 'route-b',
  ),
  const StudentModel(
    studentId: 'student-5',
    name: 'Aria Patel',
    grade: '1',
    schoolId: 'school-1',
    parentId: 'user-parent-3',
    routeId: 'route-c',
  ),
  const StudentModel(
    studentId: 'student-6',
    name: 'Kabir Patel',
    grade: '6',
    schoolId: 'school-1',
    parentId: 'user-parent-3',
    routeId: 'route-d',
  ),
];

final studentsProvider = Provider<List<StudentModel>>((ref) => _seedStudents);
