import 'dart:io';

import '../../../core/api/api_client.dart';

class ClientProfileRepository {
  final ApiClient _client;
  ClientProfileRepository(this._client);

  Future<Map<String, dynamic>> show(int leadId) => _client.get('/matchmaker/clients/$leadId/profile');

  Future<Map<String, dynamic>> store(int leadId, Map<String, dynamic> fields, {Map<String, File> files = const {}}) =>
      _client.postMultipart('/matchmaker/clients/$leadId/profile', fields: fields, files: files);

  Future<Map<String, dynamic>> submitPayment(int leadId, Map<String, dynamic> fields, File screenshot) =>
      _client.postMultipart('/matchmaker/clients/$leadId/profile/payment', fields: fields, files: {'payment_screenshot': screenshot});
}
