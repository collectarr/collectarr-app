/// Authenticated user profile returned by the auth endpoints.
///
/// Domain model that keeps the transport JSON (`/auth/*` payloads) from leaking
/// into providers and widgets.
class AuthUser {
  const AuthUser({
    this.id,
    this.email,
    this.displayName,
    this.isAdmin = false,
  });

  final String? id;
  final String? email;
  final String? displayName;
  final bool isAdmin;

  factory AuthUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AuthUser();
    }
    return AuthUser(
      id: _string(json['id']),
      email: _string(json['email']),
      displayName: _string(json['display_name']),
      isAdmin: _bool(json['is_admin']),
    );
  }

  static String? _string(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static bool _bool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return {'1', 'true', 'yes', 'admin'}.contains(value.trim().toLowerCase());
    }
    return false;
  }
}

/// A session established by login/register: the bearer token plus the user.
class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Auth response is missing access_token');
    }
    final rawUser = json['user'];
    return AuthSession(
      token: token,
      user: AuthUser.fromJson(
        rawUser is Map<String, dynamic> ? rawUser : null,
      ),
    );
  }
}
