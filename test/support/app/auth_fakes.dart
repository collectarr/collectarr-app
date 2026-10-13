import 'package:collectarr_app/state/auth_provider.dart';

class AuthenticatedAuthFake extends AuthController {
  @override
  AuthState build() => const AuthState(
      token: 'fixture-token',
      userId: 'fixture-user',
      email: 'test@example.com',
      isAdmin: true);
}

class SignedOutAuthFake extends AuthController {
  @override
  AuthState build() => const AuthState();
}
