import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Clean local persistence abstraction for PadCare.
class LocalStorage {
  static SharedPreferences? _prefs;
  static final Map<String, dynamic> _memoryCache = {};

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // In tests or headless environments fallback to memoryCache
    }
  }

  static Future<bool> setString(String key, String value) async {
    _memoryCache[key] = value;
    if (_prefs != null) {
      return await _prefs!.setString(key, value);
    }
    return true;
  }

  static String? getString(String key) {
    if (_prefs != null) {
      return _prefs!.getString(key);
    }
    return _memoryCache[key] as String?;
  }

  static Future<bool> setJson(String key, dynamic value) async {
    return await setString(key, jsonEncode(value));
  }

  static dynamic getJson(String key) {
    final raw = getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> setBool(String key, bool value) async {
    _memoryCache[key] = value;
    if (_prefs != null) {
      return await _prefs!.setBool(key, value);
    }
    return true;
  }

  static bool? getBool(String key) {
    if (_prefs != null) {
      return _prefs!.getBool(key);
    }
    return _memoryCache[key] as bool?;
  }

  static Future<bool> remove(String key) async {
    _memoryCache.remove(key);
    if (_prefs != null) {
      return await _prefs!.remove(key);
    }
    return true;
  }

  static Future<bool> clear() async {
    _memoryCache.clear();
    if (_prefs != null) {
      return await _prefs!.clear();
    }
    return true;
  }
}
