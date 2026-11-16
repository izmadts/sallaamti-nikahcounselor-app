import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Found live (16 Nov 2026): a half-filled application lost to a dropped
// connection, a phone call, or the app getting closed mid-form meant
// retyping everything from scratch. Saved locally only, on this device —
// password fields are deliberately never included, and the draft is
// cleared the moment a submission actually succeeds. Kept separate from
// SecureStore (session essentials only, by that class's own stated scope)
// since this is a different kind of thing: a draft, not session state.
class ApplyDraftStore {
  ApplyDraftStore._();
  static final _storage = const FlutterSecureStorage();
  static const _key = 'apply_draft';

  static Future<void> save(Map<String, dynamic> fields, String? selfiePhotoPath) =>
      _storage.write(key: _key, value: jsonEncode({'fields': fields, 'selfie_photo_path': selfiePhotoPath}));

  static Future<Map<String, dynamic>?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() => _storage.delete(key: _key);
}
