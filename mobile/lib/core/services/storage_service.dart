import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/constants.dart';
import '../models/user.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService(this._secureStorage, this._prefs);

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  // User management
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: AppConstants.userKey, value: userJson);
  }

  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: AppConstants.userKey);
  }

  // Theme management
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(AppConstants.themeKey, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(AppConstants.themeKey);
  }

  // Locale management
  Future<void> saveLocale(String locale) async {
    await _prefs.setString(AppConstants.localeKey, locale);
  }

  String? getLocale() {
    return _prefs.getString(AppConstants.localeKey);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
