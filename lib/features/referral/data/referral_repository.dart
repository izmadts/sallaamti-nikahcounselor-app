import '../../../core/api/api_client.dart';

class ReferralRepository {
  final ApiClient _client;
  ReferralRepository(this._client);

  Future<Map<String, dynamic>> show() => _client.get('/matchmaker/referral');
}
