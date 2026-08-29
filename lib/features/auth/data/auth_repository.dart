import '../../../core/api/api_client.dart';
import '../domain/app_user.dart';

class AuthResult {
  final AppUser user;
  final String token;
  AuthResult({required this.user, required this.token});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        user: AppUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
        token: json['token'] as String,
      );
}

// Only login/logout/me — a matchmaker account only ever comes from
// Admin\MatchmakerApplicationController::certify(), so there is no
// self-registration or OTP flow in this app (unlike the member app).
class AuthRepository {
  final ApiClient _client;
  AuthRepository(this._client);

  Future<AuthResult> login({required String login, required String password}) async {
    final data = await _client.post('/auth/login', data: {'login': login, 'password': password});
    return AuthResult.fromJson(data);
  }

  Future<void> logout() => _client.post('/auth/logout');

  Future<AppUser> me() async {
    final data = await _client.get('/auth/me');
    return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
  }
}
