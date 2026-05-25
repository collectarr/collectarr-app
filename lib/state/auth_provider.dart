import 'dart:convert';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _authTokenKey = 'collectarr.auth.token';
const _authEmailKey = 'collectarr.auth.email';
const _authIsAdminKey = 'collectarr.auth.is_admin';
const _authSecureStorage = FlutterSecureStorage();

class AuthState {
  const AuthState({
    this.token,
    this.email,
    this.expiresAt,
    this.isLoading = false,
    this.error,
    this.isRestoring = false,
    this.isAdmin = false,
  });

  final String? token;
  final String? email;
  final DateTime? expiresAt;
  final bool isLoading;
  final String? error;
  final bool isRestoring;
  final bool isAdmin;

  bool get isAuthenticated => token != null && !isExpired;
  bool get isExpired =>
      expiresAt != null && !expiresAt!.isAfter(DateTime.now().toUtc());

  AuthState copyWith({
    String? token,
    String? email,
    DateTime? expiresAt,
    bool? isLoading,
    String? error,
    bool? isRestoring,
    bool? isAdmin,
  }) {
    return AuthState(
      token: token ?? this.token,
      email: email ?? this.email,
      expiresAt: expiresAt ?? this.expiresAt,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRestoring: isRestoring ?? this.isRestoring,
      isAdmin: isAdmin ?? this.isAdmin,
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
        fallbackEmail: email,
        user: _asJsonMap(result['user']),
      );
    } catch (error) {
      state = AuthState(
        email: email,
        error: _authErrorMessage(error, isRegister: false),
      );
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
        fallbackEmail: email,
        user: _asJsonMap(result['user']),
      );
    } catch (error) {
      state = AuthState(
        email: email,
        error: _authErrorMessage(error, isRegister: true),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearStoredSession(prefs);
  }

  Future<bool> clearSessionIfRejected(Object error) async {
    if (!_isMetadataAuthSessionRejected(error)) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await _clearStoredSession(
      prefs,
      error:
          'Metadata session reset. Sign in again only if you need authenticated tools.',
    );
    return true;
  }

  Future<void> refreshCurrentUser() async {
    final token = state.token;
    if (token == null || state.isExpired) {
      return;
    }
    final user = await ref.read(apiClientProvider).currentUser();
    final email = _stringFromJson(user['email']) ?? state.email;
    final isAdmin = _boolFromJson(user['is_admin']);
    final prefs = await SharedPreferences.getInstance();
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_authEmailKey, email);
    }
    await prefs.setBool(_authIsAdminKey, isAdmin);
    state = AuthState(
      token: token,
      email: email,
      expiresAt: state.expiresAt,
      isAdmin: isAdmin,
    );
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await _readStoredToken(prefs);
      final email = prefs.getString(_authEmailKey);
      final isAdmin = prefs.getBool(_authIsAdminKey) ?? false;
      if (token != null && token.isNotEmpty) {
        final expiresAt = _jwtExpiresAt(token);
        if (_isExpired(expiresAt)) {
          await _clearStoredSession(
            prefs,
            expiresAt: expiresAt,
            error:
                'Session expired. Sign in again only if you need authenticated tools.',
          );
          return;
        }
        ref.read(apiAuthTokenProvider.notifier).set(token);
        ref.read(apiClientProvider).setToken(token);
        state = AuthState(
          token: token,
          email: email,
          expiresAt: expiresAt,
          isAdmin: isAdmin,
        );
      } else {
        ref.read(apiAuthTokenProvider.notifier).set(null);
        state = AuthState(email: email);
      }
    } catch (error) {
      ref.read(apiAuthTokenProvider.notifier).set(null);
      state = AuthState(error: error.toString());
    }
  }

  Future<void> _persistSession({
    required String token,
    required String fallbackEmail,
    required Map<String, dynamic>? user,
  }) async {
    final email = _stringFromJson(user?['email']) ?? fallbackEmail;
    final isAdmin = _boolFromJson(user?['is_admin']);
    final prefs = await SharedPreferences.getInstance();
    await _authSecureStorage.write(key: _authTokenKey, value: token);
    await prefs.remove(_authTokenKey);
    await prefs.setString(_authEmailKey, email);
    await prefs.setBool(_authIsAdminKey, isAdmin);
    ref.read(apiAuthTokenProvider.notifier).set(token);
    ref.read(apiClientProvider).setToken(token);
    state = AuthState(
      token: token,
      email: email,
      expiresAt: _jwtExpiresAt(token),
      isAdmin: isAdmin,
    );
  }

  Future<void> _clearStoredSession(
    SharedPreferences prefs, {
    String? error,
    DateTime? expiresAt,
  }) async {
    final email = prefs.getString(_authEmailKey) ?? state.email;
    try {
      await _authSecureStorage.delete(key: _authTokenKey);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'auth',
        message: 'Failed to delete secure token during session clear.',
        error: error,
        stackTrace: stackTrace,
      );
    }
    await prefs.remove(_authTokenKey);
    await prefs.remove(_authIsAdminKey);
    ref.read(apiAuthTokenProvider.notifier).set(null);
    ref.read(apiClientProvider).clearToken();
    state = AuthState(email: email, expiresAt: expiresAt, error: error);
  }

  Future<String?> _readStoredToken(SharedPreferences prefs) async {
    final secureToken = await _authSecureStorage.read(key: _authTokenKey);
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }
    final legacyToken = prefs.getString(_authTokenKey);
    if (legacyToken == null || legacyToken.isEmpty) {
      return null;
    }
    await _authSecureStorage.write(key: _authTokenKey, value: legacyToken);
    await prefs.remove(_authTokenKey);
    return legacyToken;
  }
}

Map<String, dynamic>? _asJsonMap(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}

String? _stringFromJson(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

bool _boolFromJson(Object? value) {
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

DateTime? _jwtExpiresAt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    return null;
  }
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload is Map<String, dynamic> ? payload['exp'] : null;
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    }
    if (exp is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        (exp * 1000).round(),
        isUtc: true,
      );
    }
  } catch (error, stackTrace) {
    logRecoverableError(
      source: 'auth',
      message: 'Failed to parse JWT expiration timestamp.',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
  return null;
}

bool _isExpired(DateTime? expiresAt) {
  return expiresAt != null && !expiresAt.isAfter(DateTime.now().toUtc());
}

bool _isMetadataAuthSessionRejected(Object error) {
  if (error is! DioException || error.response?.statusCode != 401) {
    return false;
  }
  final data = error.response?.data;
  final code = data is Map ? data['code']?.toString() : null;
  final detail = data is Map ? data['detail']?.toString() : null;
  return {
        'invalid_bearer_token',
        'user_not_found',
      }.contains(code) ||
      {
        'Invalid bearer token',
        'User not found',
      }.contains(detail);
}

String _authErrorMessage(Object error, {required bool isRegister}) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (!isRegister && (statusCode == 401 || statusCode == 403)) {
      return 'Invalid email or password.';
    }
    if (isRegister && statusCode == 409) {
      return 'An account already exists for this email.';
    }
    if (statusCode != null) {
      if (statusCode == 422) {
        return 'Check the email and password fields.';
      }
      if (statusCode == 429) {
        return 'Too many sign-in attempts. Try again later.';
      }
      if (statusCode >= 500) {
        return 'The metadata server could not complete authentication. Try again later.';
      }
      return 'Authentication request was rejected. Check Settings connection.';
    }
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Could not reach the metadata server. Check Settings connection.',
      DioExceptionType.badCertificate =>
        'Metadata server TLS certificate was rejected.',
      DioExceptionType.cancel => 'Authentication request was cancelled.',
      DioExceptionType.badResponse => 'Unexpected authentication response.',
      DioExceptionType.unknown =>
        'Authentication failed: ${_cleanError(error.message)}',
    };
  }
  return 'Authentication failed: $error';
}

String _cleanError(String? message) {
  final value = message?.trim();
  if (value == null || value.isEmpty) {
    return 'unknown error';
  }
  return value;
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
