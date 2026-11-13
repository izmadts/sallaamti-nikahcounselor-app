import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// One shared secure-storage box for the small bits of session state that
// need to survive an app restart: the Sanctum bearer token, the last-known
// user profile, and the user's chosen language. Deliberately not a full
// key-value cache — anything else belongs in Riverpod state, refetched from
// the API when needed.
class SecureStore {
  SecureStore._();
  static final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _localeKey = 'locale_code';

  static Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  static Future<String?> readToken() => _storage.read(key: _tokenKey);
  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // Cached alongside the token purely so a session restore has something to
  // show when /auth/me can't be reached (no connectivity, server hiccup) —
  // not a source of truth, just lets the dashboard open instead of bouncing
  // to the login screen for a reason that has nothing to do with the token.
  static Future<void> saveUser(Map<String, dynamic> json) => _storage.write(key: _userKey, value: jsonEncode(json));
  static Future<void> clearUser() => _storage.delete(key: _userKey);
  static Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLocale(String code) => _storage.write(key: _localeKey, value: code);
  static Future<String?> readLocale() => _storage.read(key: _localeKey);
}
