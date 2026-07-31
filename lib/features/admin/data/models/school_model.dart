import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  final String schoolId;
  final String name;
  final String address;
  final String adminId;

  const SchoolModel({
    required this.schoolId,
    required this.name,
    required this.address,
    required this.adminId,
  });

  factory SchoolModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SchoolModel(
      schoolId: doc.id,
      name: d['name'] as String? ?? '',
      address: d['address'] as String? ?? '',
      adminId: d['adminId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
      };
}
