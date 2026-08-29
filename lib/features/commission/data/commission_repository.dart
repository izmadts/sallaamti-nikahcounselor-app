import '../../../core/api/api_client.dart';

class CommissionRepository {
  final ApiClient _client;
  CommissionRepository(this._client);

  Future<Map<String, dynamic>> index() => _client.get('/matchmaker/commissions');
}
