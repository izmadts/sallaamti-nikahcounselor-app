import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/push/push_notification_service.dart';
import '../../../core/storage/secure_store.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

enum AuthStatus { checking, authenticated, unauthenticated, pendingApplication }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  // Only set when status == pendingApplication — the raw
  // /matchmaker/application response, same shape ApplicationScreen already
  // renders (status_label, steps, step_index, is_terminal, ...).
  final Map<String, dynamic>? applicationStatus;

  const AuthState({required this.status, this.user, this.applicationStatus});

  const AuthState.checking() : this(status: AuthStatus.checking);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.authenticated(AppUser user) : this(status: AuthStatus.authenticated, user: user);
  const AuthState.pendingApplication(AppUser user, Map<String, dynamic> applicationStatus)
      : this(status: AuthStatus.pendingApplication, user: user, applicationStatus: applicationStatus);
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider), ref.watch(pushNotificationServiceProvider)),
);

// Every method either lands on AuthStatus.authenticated with a fresh user,
// or throws an ApiException the calling screen catches to show inline.
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final PushNotificationService _push;
  late final Future<void> _restoring;

  AuthController(this._repository, this._push) : super(const AuthState.checking()) {
    _restoring = _restoreSession();
  }

  // Mirrors LocaleController.ensureRestored() — awaited by the splash
  // screen so it acts on the real restored session instead of a
  // build-time snapshot that might still read `checking`.
  Future<AuthState> ensureRestored() async {
    await _restoring;
    return state;
  }

  // Fire-and-forget — a device-token registration failure (permission
  // denied, Firebase not reachable, etc.) must never block sign-in.
  void _registerPushSafely() {
    _push.registerThisDevice().catchError((Object e, StackTrace st) {
      if (kDebugMode) debugPrint('Push registration failed: $e');
    });
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
        await _settleNonCounselor(user);
        return;
      }
      state = AuthState.authenticated(user);
      _registerPushSafely();
    } on ApiException {
      await SecureStore.clearToken();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String login, required String password}) =>
      _acceptIfCounselor(_repository.login(login: login, password: password));

  // Re-checks application status from the waiting screen (e.g. pull to
  // refresh) — a no-op if the applicant has since been certified elsewhere,
  // since the next full login/restore will pick up the real role then; this
  // just keeps the on-screen status/step chips current meanwhile.
  Future<void> refreshPendingStatus() async {
    if (state.status != AuthStatus.pendingApplication || state.user == null) return;
    try {
      final status = await _repository.applicationStatus();
      state = AuthState.pendingApplication(state.user!, status);
    } on ApiException {
      // Keep showing the last known status rather than bouncing the screen.
    }
  }

  Future<String> forgotPassword(String email) => _repository.forgotPassword(email);

  Future<void> resetPassword({required String email, required String code, required String password}) =>
      _acceptIfCounselor(_repository.resetPassword(email: email, code: code, password: password));

  // Both ways into this app end here. /auth/login and /auth/password/reset
  // are role-agnostic by design (any account can use them) — the real backend
  // security boundary is EnsureUserIsMatchmakerApi on every matchmaker.*
  // route. This is a client-side courtesy so a non-counselor account sees a
  // clear message (or, for a genuine pending applicant, the waiting screen)
  // instead of a broken empty dashboard where every screen 403s.
  Future<void> _acceptIfCounselor(Future<AuthResult> pending) async {
    final result = await pending;
    await SecureStore.saveToken(result.token);

    if (!result.user.isMatchmaker) {
      await _settleNonCounselor(result.user);
      if (state.status != AuthStatus.pendingApplication) {
        throw ApiException(message: 'not_counselor_account');
      }
      return;
    }

    state = AuthState.authenticated(result.user);
    _registerPushSafely();
  }

  // A non-matchmaker-role account is either a genuine pending applicant
  // (shown the waiting screen, token kept so it can poll its own status and
  // log out) or an unrelated account with no application at all / a
  // rejected-withdrawn one (token dropped, same as before this screen
  // existed).
  Future<void> _settleNonCounselor(AppUser user) async {
    try {
      final status = await _repository.applicationStatus();
      final hasApplication = status['has_application'] as bool? ?? false;
      final isTerminal = status['is_terminal'] as bool? ?? false;
      if (hasApplication && !isTerminal) {
        state = AuthState.pendingApplication(user, status);
        return;
      }
    } on ApiException {
      // Couldn't even check — fall through to the generic non-counselor path
      // below rather than leaving the app stuck on a blank authenticated-ish
      // state.
    }

    try {
      await _repository.logout();
    } on ApiException {
      // Token may already be unusable — proceed regardless.
    }
    await SecureStore.clearToken();
    state = const AuthState.unauthenticated();
  }

  Future<void> logout() async {
    // Best-effort, and must happen before the token is cleared below — the
    // unregister call needs to still be authenticated to reach this device's
    // own device-token row.
    try {
      await _push.unregisterThisDevice();
    } catch (_) {
      // Not fatal — a stale token server-side just means a future send to
      // it fails silently on Firebase's end.
    }
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
