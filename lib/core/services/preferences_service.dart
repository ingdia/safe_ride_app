import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();

  static final PreferencesService instance = PreferencesService._();

  static const String _lastSignedInEmailKey = 'last_signed_in_email';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<void> saveLastSignedInEmail(String? email) async {
    final prefs = await _prefs;
    if (email == null) {
      await prefs.remove(_lastSignedInEmailKey);
      return;
    }
    await prefs.setString(_lastSignedInEmailKey, email);
  }

  Future<String?> getLastSignedInEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_lastSignedInEmailKey);
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_isLoggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
}
