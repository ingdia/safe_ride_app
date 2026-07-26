class ParentFirestorePaths {
  const ParentFirestorePaths._();

  static const String trips = 'trips';

  static String tripDocument(String tripId) {
    return '$trips/$tripId';
  }
}
