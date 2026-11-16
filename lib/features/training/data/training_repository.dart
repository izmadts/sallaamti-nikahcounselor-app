import '../../../core/api/api_client.dart';

// Trainee-access addendum (15/16 Nov 2026). Guide content is local Dart
// (TrainingGuideContent, same convention as the existing /guide screen) —
// only the quiz needs the backend, since grading must be
// server-authoritative.
class TrainingRepository {
  final ApiClient _client;
  TrainingRepository(this._client);

  Future<List<Map<String, dynamic>>> questions() async {
    final res = await _client.get('/matchmaker/training/quiz');
    return List<Map<String, dynamic>>.from((res['questions'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
  }

  Future<Map<String, dynamic>> submit(List<Map<String, dynamic>> answers) =>
      _client.post('/matchmaker/training/quiz/submit', data: {'answers': answers});

  Future<List<Map<String, dynamic>>> attempts() async {
    final res = await _client.get('/matchmaker/training/quiz/attempts');
    return List<Map<String, dynamic>>.from((res['attempts'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
  }
}
