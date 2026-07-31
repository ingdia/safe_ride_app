import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolEntity {
  const SchoolEntity({required this.id, required this.name});

  final String id;
  final String name;

  factory SchoolEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SchoolEntity(id: doc.id, name: d['name'] as String? ?? '');
  }
}
