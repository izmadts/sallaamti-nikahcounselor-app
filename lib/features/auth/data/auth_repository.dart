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

// Login/logout/me plus password recovery — an account is created as soon as
// someone applies (NikahCounselorApplicationController::store()), and only
// gains the actual 'matchmaker' role once Admin\MatchmakerApplicationController
// advances the application all the way to 'certified'. So there is no
// self-registration/OTP flow here (unlike the member app) but there IS a
// window where an account exists and can log in without the role yet — see
// AuthController._acceptIfCounselor(). Forgetting the password chosen at
// apply time is very much a thing that happens, hence the reset pair below.
class AuthRepository {
  final ApiClient _client;
  AuthRepository(this._client);

  Future<AuthResult> login({required String login, required String password}) async {
    final data = await _client.post('/auth/login', data: {'login': login, 'password': password});
    return AuthResult.fromJson(data);
  }

  // Self-scoped to the token's own account server-side — safe to call for
  // any authenticated user, matchmaker role or not. Returns `has_application:
  // false` for an account with no application at all.
  Future<Map<String, dynamic>> applicationStatus() => _client.get('/matchmaker/application');

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
