/// Single source of truth for every Firestore collection name.
/// Import this wherever you need a collection reference so a rename
/// only ever requires changing one file.
class FirebaseCollections {
  FirebaseCollections._();

  static const String users = 'users';
  static const String schools = 'schools';
  static const String buses = 'buses';
  static const String routes = 'routes';
  static const String students = 'students';
  static const String attendance = 'attendance';
  static const String notifications = 'notifications';
  static const String sosAlerts = 'sos_alerts';
}
