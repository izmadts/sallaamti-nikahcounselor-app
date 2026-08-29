import 'dart:io';

import '../../../core/api/api_client.dart';

class ApplyRepository {
  final ApiClient _client;
  ApplyRepository(this._client);

  Future<Map<String, dynamic>> enums() => _client.get('/meta/nikah-counselor-application');

  Future<Map<String, dynamic>> submit(Map<String, dynamic> fields, Map<String, File> files) =>
      _client.postMultipart('/nikah-counselor-application', fields: fields, files: files);
}
