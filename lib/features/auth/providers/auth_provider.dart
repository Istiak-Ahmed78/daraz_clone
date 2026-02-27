import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

// ── Auth Status ───────────────────────────────────────────────────────────────
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// ── Auth State ────────────────────────────────────────────────────────────────
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// FIX: Added `clearError` flag so errorMessage can be explicitly
  /// set back to null. Without this, once an error is set, copyWith
  /// can never clear it because of the `?? this.errorMessage` fallback.
  AuthState copyWith({
    AuthStatus? status,
    UserProfile? profile,
    String? errorMessage,
    bool clearError = false, // ← KEY FIX
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    _checkSession();
  }

  final AuthRepository _repo;

  /// On app start — check if token already exists in storage.
  Future<void> _checkSession() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final loggedIn = await _repo.isLoggedIn();
      if (loggedIn) {
        // FakeStore has no "me" endpoint, so we fetch user id=1 as demo.
        final profile = await _repo.fetchProfile(1);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          profile: profile,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearError: true,
        );
      }
    } on AuthException catch (e) {
      // Session check failure → treat as unauthenticated, not error
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearError: true,
      );
    }
  }

  /// Login with username and password.
  Future<void> login(String username, String password) async {
    // Clear previous error before new attempt
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _repo.login(username, password);
      final profile = await _repo.fetchProfile(1);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        profile: profile,
        clearError: true,
      );
    } on AuthException catch (e) {
      // Typed error from repository — safe to show to user
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      // Unexpected error fallback
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Unexpected error. Please try again.',
      );
    }
  }

  /// Logout — clears token and resets state fully.
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
