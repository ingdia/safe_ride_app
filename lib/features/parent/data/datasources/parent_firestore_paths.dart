class ParentFirestorePaths {
  const ParentFirestorePaths._();

  static const String activeParentId = 'parent_001';

  static const String trips = 'trips';
  static const String parents = 'parents';
  static const String notifications = 'notifications';

  static String tripDocument(String tripId) {
    return '$trips/$tripId';
  }

  static String parentDocument(String parentId) {
    return '$parents/$parentId';
  }

  static String parentChildren(String parentId) {
    return '$parents/$parentId/children';
  }
}
