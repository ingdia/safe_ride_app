import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String studentId;
  final String name;
  final String grade;
  final String schoolId;
  final String parentId;
  final String routeId;

  const StudentModel({
    required this.studentId,
    required this.name,
    required this.grade,
    required this.schoolId,
    required this.parentId,
    required this.routeId,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      studentId: doc.id,
      name: data['name'] as String? ?? '',
      grade: data['grade'] as String? ?? '',
      schoolId: data['school_id'] as String? ?? '',
      parentId: data['parent_id'] as String? ?? '',
      routeId: data['route_id'] as String? ?? '',
    );
  }
}
