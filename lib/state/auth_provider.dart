import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({this.token, this.isLoading = false, this.error});

  final String? token;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => token != null;

  AuthState copyWith({String? token, bool? isLoading, String? error}) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref) : super(const AuthState());

  final Ref ref;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await ref
          .read(apiClientProvider)
          .login(email: email, password: password);
      state = AuthState(token: result['access_token'] as String);
    } catch (error) {
      state = AuthState(error: error.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await ref
          .read(apiClientProvider)
          .register(email: email, password: password);
      state = AuthState(token: result['access_token'] as String);
    } catch (error) {
      state = AuthState(error: error.toString());
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
