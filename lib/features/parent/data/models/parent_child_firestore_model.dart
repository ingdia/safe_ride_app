import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/parent_child_entity.dart';
import '../datasources/parent_firestore_fields.dart';

class ParentChildFirestoreModel {
  const ParentChildFirestoreModel._();

  static ParentChildEntity fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    if (data == null) {
      return fallback(snapshot.id);
    }

    return ParentChildEntity(
      id: snapshot.id,
      fullName: _readString(data, ParentChildFields.fullName, 'Ineza Uwase'),
      grade: _readString(data, ParentChildFields.grade, 'Primary 4'),
      busNumber: _readString(data, ParentChildFields.busNumber, 'Bus #12'),
      pickupStop: _readString(data, ParentChildFields.pickupStop, 'Kacyiru'),
    );
  }

  static ParentChildEntity fallback(String childId) {
    return ParentChildEntity(
      id: childId,
      fullName: 'Ineza Uwase',
      grade: 'Primary 4',
      busNumber: 'Bus #12',
      pickupStop: 'Kacyiru',
    );
  }

  static Map<String, Object> toCreateMap(ParentChildEntity child) {
    final cleanChild = _trimChild(child);

    return {
      ParentChildFields.fullName: cleanChild.fullName,
      ParentChildFields.grade: cleanChild.grade,
      ParentChildFields.busNumber: cleanChild.busNumber,
      ParentChildFields.pickupStop: cleanChild.pickupStop,
      ParentChildFields.createdAt: FieldValue.serverTimestamp(),
      ParentChildFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  static Map<String, Object> toUpdateMap(ParentChildEntity child) {
    final cleanChild = _trimChild(child);

    return {
      ParentChildFields.fullName: cleanChild.fullName,
      ParentChildFields.grade: cleanChild.grade,
      ParentChildFields.busNumber: cleanChild.busNumber,
      ParentChildFields.pickupStop: cleanChild.pickupStop,
      ParentChildFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  static ParentChildEntity _trimChild(ParentChildEntity child) {
    return child.copyWith(
      fullName: child.fullName.trim(),
      grade: child.grade.trim(),
      busNumber: child.busNumber.trim(),
      pickupStop: child.pickupStop.trim(),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key,
    String fallbackValue,
  ) {
    final value = data[key];

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return fallbackValue;
  }
}
