import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/parent_profile_entity.dart';
import '../datasources/parent_firestore_fields.dart';

class ParentProfileFirestoreModel {
  const ParentProfileFirestoreModel._();

  static ParentProfileEntity fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    if (data == null) {
      return fallback(snapshot.id);
    }

    return ParentProfileEntity(
      parentId: snapshot.id,
      fullName: _readString(
        data,
        ParentProfileFields.fullName,
        'Uwimana Claudine',
      ),
      phoneNumber: _readString(
        data,
        ParentProfileFields.phoneNumber,
        '+250 788 000 111',
      ),
      email: _readString(data, ParentProfileFields.email, 'parent@saferide.rw'),
      homeAddress: _readString(
        data,
        ParentProfileFields.homeAddress,
        'Kacyiru, Kigali',
      ),
      preferredLanguage: _readString(
        data,
        ParentProfileFields.preferredLanguage,
        'English',
      ),
    );
  }

  static ParentProfileEntity fallback(String parentId) {
    return ParentProfileEntity(
      parentId: parentId,
      fullName: 'Uwimana Claudine',
      phoneNumber: '+250 788 000 111',
      email: 'parent@saferide.rw',
      homeAddress: 'Kacyiru, Kigali',
      preferredLanguage: 'English',
    );
  }

  static Map<String, Object> toUpdateMap(ParentProfileEntity profile) {
    final cleanProfile = profile.trimmed();

    return {
      ParentProfileFields.fullName: cleanProfile.fullName,
      ParentProfileFields.phoneNumber: cleanProfile.phoneNumber,
      ParentProfileFields.email: cleanProfile.email,
      ParentProfileFields.homeAddress: cleanProfile.homeAddress,
      ParentProfileFields.preferredLanguage: cleanProfile.preferredLanguage,
      ParentProfileFields.updatedAt: FieldValue.serverTimestamp(),
    };
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
