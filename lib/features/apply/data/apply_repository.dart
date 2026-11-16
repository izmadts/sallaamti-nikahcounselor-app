import 'dart:io';

import '../../../core/api/api_client.dart';

class ApplyRepository {
  final ApiClient _client;
  ApplyRepository(this._client);

  Future<Map<String, dynamic>> enums() => _client.get('/meta/nikah-counselor-application');

  // Called the moment the selfie is picked, well before the rest of the
  // form is filled in — so a slow connection only risks this one small
  // upload, not the applicant's whole typed-in form (16 Nov 2026 fix).
  // Returns the stored path to send back as selfie_photo_path on submit().
  Future<String> uploadSelfie(File file) async {
    final res = await _client.postMultipart('/nikah-counselor-application/selfie', files: {'selfie_photo': file});
    return res['path'] as String;
  }

  // No files here any more — selfie_photo_path (from uploadSelfie() above)
  // replaces the raw file, so this is a plain JSON post, not multipart.
  Future<Map<String, dynamic>> submit(Map<String, dynamic> fields) => _client.post('/nikah-counselor-application', data: fields);
}
