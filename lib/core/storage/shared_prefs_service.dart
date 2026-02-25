import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class SharedPrefsService {
  SharedPrefsService(this._prefs);

  final SharedPreferences _prefs;

  String? readToken() => _prefs.getString(AppConstants.tokenStorageKey);

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenStorageKey, token);
  }

  String? readUserJson() => _prefs.getString(AppConstants.userStorageKey);

  Future<void> saveUserJson(String userJson) async {
    await _prefs.setString(AppConstants.userStorageKey, userJson);
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.tokenStorageKey);
    await _prefs.remove(AppConstants.userStorageKey);
  }
}
