import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/storage/secure_store.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;

  const AuthState({required this.status, this.user});

  const AuthState.checking() : this(status: AuthStatus.checking);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.authenticated(AppUser user) : this(status: AuthStatus.authenticated, user: user);
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);

// Every method either lands on AuthStatus.authenticated with a fresh user,
// or throws an ApiException the calling screen catches to show inline.
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState.checking()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await SecureStore.readToken();
    if (token == null) {
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      final user = await _repository.me();
      if (!user.isMatchmaker) {
        await SecureStore.clearToken();
        state = const AuthState.unauthenticated();
        return;
      }
      state = AuthState.authenticated(user);
    } on ApiException {
      await SecureStore.clearToken();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String login, required String password}) async {
    final result = await _repository.login(login: login, password: password);

    // auth/login is role-agnostic by design (any account can log in) — the
    // real backend security boundary is EnsureUserIsMatchmakerApi on every
    // matchmaker.* route. This is a client-side courtesy so a non-counselor
    // credential pair sees a clear message instead of a broken empty
    // dashboard where every screen 403s.
    if (!result.user.isMatchmaker) {
      await SecureStore.saveToken(result.token);
      try {
        await _repository.logout();
      } on ApiException {
        // Token may already be unusable — proceed regardless.
      }
      await SecureStore.clearToken();
      throw ApiException(message: 'not_counselor_account');
    }

    await SecureStore.saveToken(result.token);
    state = AuthState.authenticated(result.user);
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } on ApiException {
      // Token may already be invalid server-side — proceed to clear the
      // local session regardless, since the user's intent is to be logged
      // out either way.
    }
    await SecureStore.clearToken();
    state = const AuthState.unauthenticated();
  }
}
