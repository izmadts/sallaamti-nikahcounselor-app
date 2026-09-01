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

// Login/logout/me plus password recovery — a matchmaker account only ever
// comes from Admin\MatchmakerApplicationController::certify(), so there is no
// self-registration or OTP login flow in this app (unlike the member app).
// Forgetting the password admin handed out at certification, though, is very
// much a thing that happens, hence the reset pair below.
class AuthRepository {
  final ApiClient _client;
  AuthRepository(this._client);

  Future<AuthResult> login({required String login, required String password}) async {
    final data = await _client.post('/auth/login', data: {'login': login, 'password': password});
    return AuthResult.fromJson(data);
  }

  // Shared with the member app — /auth/password/* is role-agnostic, and
  // AuthController below applies the same counselor-only courtesy check it
  // applies to login.
  Future<String> forgotPassword(String email) async {
    final data = await _client.post('/auth/password/forgot', data: {'email': email});
    return data['message'] as String? ?? '';
  }

  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final data = await _client.post('/auth/password/reset', data: {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': password,
    });
    return AuthResult.fromJson(data);
  }

  Future<void> logout() => _client.post('/auth/logout');

  Future<AppUser> me() async {
    final data = await _client.get('/auth/me');
    return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
  }
}
