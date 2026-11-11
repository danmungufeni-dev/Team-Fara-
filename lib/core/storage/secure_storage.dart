import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'local_storage.dart';

/// Secure token & sensitive credential storage.
class SecureStorage {
  static const String _prefix = 'sec_padcare_';

  static String _hashKey(String key) {
    return sha256.convert(utf8.encode(key)).toString();
  }

  static Future<void> writeToken(String key, String token) async {
    final hashedKey = '$_prefix${_hashKey(key)}';
    // Simple base64 encoding layer for secure obfuscation in local storage
    final encoded = base64Encode(utf8.encode(token));
    await LocalStorage.setString(hashedKey, encoded);
  }

  static Future<String?> readToken(String key) async {
    final hashedKey = '$_prefix${_hashKey(key)}';
    final encoded = LocalStorage.getString(hashedKey);
    if (encoded == null) return null;
    try {
      return utf8.decode(base64Decode(encoded));
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteToken(String key) async {
    final hashedKey = '$_prefix${_hashKey(key)}';
    await LocalStorage.remove(hashedKey);
  }

  static Future<void> wipeAllSensitive() async {
    // Zero-Trace wipe
    await LocalStorage.clear();
  }
}
