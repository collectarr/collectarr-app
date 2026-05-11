import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _authTokenKey = 'collectarr.auth.token';
const _authEmailKey = 'collectarr.auth.email';

class AuthState {
  const AuthState({
    this.token,
    this.email,
    this.isLoading = false,
    this.error,
    this.isRestoring = false,
  });

  final String? token;
  final String? email;
  final bool isLoading;
  final String? error;
  final bool isRestoring;

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    String? token,
    String? email,
    bool? isLoading,
    String? error,
    bool? isRestoring,
  }) {
    return AuthState(
      token: token ?? this.token,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref) : super(const AuthState(isRestoring: true)) {
    _restoreSession();
  }

  final Ref ref;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ref
          .read(apiClientProvider)
          .login(email: email, password: password);
      await _persistSession(
        token: result['access_token'] as String,
        email: email,
      );
    } catch (error) {
      state = AuthState(email: email, error: error.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ref
          .read(apiClientProvider)
          .register(email: email, password: password);
      await _persistSession(
        token: result['access_token'] as String,
        email: email,
      );
    } catch (error) {
      state = AuthState(email: email, error: error.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    state = AuthState(email: prefs.getString(_authEmailKey));
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_authTokenKey);
      final email = prefs.getString(_authEmailKey);
      if (token != null && token.isNotEmpty) {
        ref.read(apiClientProvider).setToken(token);
        state = AuthState(token: token, email: email);
      } else {
        state = AuthState(email: email);
      }
    } catch (error) {
      state = AuthState(error: error.toString());
    }
  }

  Future<void> _persistSession({
    required String token,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_authEmailKey, email);
    ref.read(apiClientProvider).setToken(token);
    state = AuthState(token: token, email: email);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
