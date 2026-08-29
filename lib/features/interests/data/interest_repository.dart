import '../../../core/api/api_client.dart';

class InterestRepository {
  final ApiClient _client;
  InterestRepository(this._client);

  Future<Map<String, dynamic>> index() => _client.get('/matchmaker/interests');

  Future<Map<String, dynamic>> accept(int interestId) => _client.post('/matchmaker/interests/$interestId/accept');

  Future<Map<String, dynamic>> decline(int interestId) => _client.post('/matchmaker/interests/$interestId/decline');
}
