import '../../../core/api/api_client.dart';

class ClientRepository {
  final ApiClient _client;
  ClientRepository(this._client);

  Future<Map<String, dynamic>> index({String? status, String? search}) => _client.get('/matchmaker/clients', query: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      });

  Future<Map<String, dynamic>> create(Map<String, dynamic> fields) => _client.post('/matchmaker/clients', data: fields);

  Future<Map<String, dynamic>> show(int leadId) => _client.get('/matchmaker/clients/$leadId');

  Future<Map<String, dynamic>> update(int leadId, Map<String, dynamic> fields) => _client.patch('/matchmaker/clients/$leadId', data: fields);

  Future<Map<String, dynamic>> saveRequirement(int leadId, {String? notes, required List<Map<String, dynamic>> items}) =>
      _client.post('/matchmaker/clients/$leadId/requirements', data: {'notes': notes, 'items': items});

  Future<Map<String, dynamic>> addToShortlist(int leadId, int nikahProfileId, {String? note}) =>
      _client.post('/matchmaker/clients/$leadId/shortlist', data: {'nikah_profile_id': nikahProfileId, 'note': note});

  Future<void> removeFromShortlist(int leadId, int itemId) => _client.delete('/matchmaker/clients/$leadId/shortlist/$itemId');

  Future<Map<String, dynamic>> recordConsent(int leadId, {required String consentType, required String method, String? notes}) =>
      _client.post('/matchmaker/clients/$leadId/consents', data: {'consent_type': consentType, 'method': method, 'notes': notes});

  Future<Map<String, dynamic>> requestConsent(int leadId, String consentType) =>
      _client.post('/matchmaker/clients/$leadId/consents/request', data: {'consent_type': consentType});

  Future<Map<String, dynamic>> revokeConsent(int leadId, int consentId) => _client.post('/matchmaker/clients/$leadId/consents/$consentId/revoke');

  Future<Map<String, dynamic>> regenerateProgressLink(int leadId) => _client.post('/matchmaker/clients/$leadId/progress-link');

  Future<Map<String, dynamic>> createBatch(int leadId) => _client.post('/matchmaker/clients/$leadId/proposal-batches');

  Future<Map<String, dynamic>> addProposal(int leadId, int batchId, int candidateProfileId) =>
      _client.post('/matchmaker/clients/$leadId/proposal-batches/$batchId/proposals', data: {'candidate_profile_id': candidateProfileId});

  Future<void> removeProposal(int leadId, int batchId, int proposalId) =>
      _client.delete('/matchmaker/clients/$leadId/proposal-batches/$batchId/proposals/$proposalId');

  Future<Map<String, dynamic>> sendBatch(int leadId, int batchId) => _client.post('/matchmaker/clients/$leadId/proposal-batches/$batchId/send');

  Future<Map<String, dynamic>> regenerateProposalLink(int leadId, int batchId, int proposalId) =>
      _client.post('/matchmaker/clients/$leadId/proposal-batches/$batchId/proposals/$proposalId/regenerate-link');
}
