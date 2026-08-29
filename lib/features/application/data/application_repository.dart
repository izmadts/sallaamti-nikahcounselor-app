import '../../../core/api/api_client.dart';

class ApplicationRepository {
  final ApiClient _client;
  ApplicationRepository(this._client);

  Future<Map<String, dynamic>> show() => _client.get('/matchmaker/application');
}
