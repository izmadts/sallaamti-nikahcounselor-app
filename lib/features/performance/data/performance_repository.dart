import '../../../core/api/api_client.dart';

class PerformanceRepository {
  final ApiClient _client;
  PerformanceRepository(this._client);

  Future<Map<String, dynamic>> index() => _client.get('/matchmaker/performance');
}
