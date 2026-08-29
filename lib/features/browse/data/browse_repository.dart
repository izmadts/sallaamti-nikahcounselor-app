import '../../../core/api/api_client.dart';

class BrowseRepository {
  final ApiClient _client;
  BrowseRepository(this._client);

  Future<Map<String, dynamic>> index(Map<String, String> filters) => _client.get('/matchmaker/browse', query: filters);

  Future<Map<String, dynamic>> show(int profileId) => _client.get('/matchmaker/browse/$profileId');

  Future<Map<String, dynamic>> requestContact(int profileId) => _client.post('/matchmaker/browse/$profileId/request-contact');
}
