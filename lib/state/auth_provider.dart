import 'dart:async';
import 'dart:convert';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/auth_session.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _authTokenKey = 'collectarr.auth.token';
const _authEmailKey = 'collectarr.auth.email';
const _authUserIdKey = 'collectarr.auth.user_id';
const _authIsAdminKey = 'collectarr.auth.is_admin';
const _authSecureStorage = FlutterSecureStorage();
const _authRestoreTimeout = Duration(seconds: 3);
const _secureStorageReadTimeout = Duration(seconds: 2);
const _devAuthEmail = 'user@example.com';
const _devAuthPassword = 'password123';
const _debugWebPreviewToken =
    'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJleHAiOjQxMDI0NDQ4MDB9.';

class AuthState {
  const AuthState({
    this.token,
    this.userId,
    this.email,
    this.expiresAt,
    this.isLoading = false,
    this.error,
    this.isRestoring = false,
    this.isAdmin = false,
  });

  final String? token;
  final String? userId;
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
    String? userId,
    String? email,
    DateTime? expiresAt,
    bool? isLoading,
    String? error,
    bool? isRestoring,
    bool? isAdmin,
  }) {
    return AuthState(
      token: token ?? this.token,
      userId: userId ?? this.userId,
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
    _startRestoreSession();
  }

  final Ref ref;

  Future<void> _startRestoreSession() async {
    try {
      await _restoreSession().timeout(_authRestoreTimeout);
    } on TimeoutException catch (error, stackTrace) {
      logRecoverableError(
        source: 'auth',
        message: 'Timed out restoring the persisted auth session.',
        error: error,
        stackTrace: stackTrace,
      );
      ref.read(apiAuthTokenProvider.notifier).set(null);
      ref.read(apiClientProvider).clearToken();
      state = const AuthState();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ref
          .read(apiClientProvider)
          .login(email: email, password: password);
      await _persistSession(session: result);
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
      await _persistSession(session: result);
    } catch (error) {
      state = AuthState(
        email: email,
        error: _authErrorMessage(error, isRegister: true),
      );
    }
  }

  Future<void> loginWithDevCredentials() async {
    state = state.copyWith(isLoading: true, error: null, email: _devAuthEmail);
    final client = ref.read(apiClientProvider);
    try {
      final result = await client.login(
        email: _devAuthEmail,
        password: _devAuthPassword,
      );
      await _persistSession(session: result);
      return;
    } catch (error) {
      if (error is DioException) {
        final status = error.response?.statusCode;
        if (status == 401 || status == 403) {
          try {
            final result = await client.register(
              email: _devAuthEmail,
              password: _devAuthPassword,
            );
            await _persistSession(session: result);
            return;
          } catch (registerError) {
            if (registerError is DioException &&
                registerError.response?.statusCode == 409) {
              try {
                final retry = await client.login(
                  email: _devAuthEmail,
                  password: _devAuthPassword,
                );
                await _persistSession(session: retry);
                return;
              } catch (retryError) {
                state = AuthState(
                  email: _devAuthEmail,
                  error: _authErrorMessage(retryError, isRegister: false),
                );
                return;
              }
            }
            state = AuthState(
              email: _devAuthEmail,
              error: _authErrorMessage(registerError, isRegister: true),
            );
            return;
          }
        }
      }
      state = AuthState(
        email: _devAuthEmail,
        error: _authErrorMessage(error, isRegister: false),
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
    final userId = user.id ?? state.userId;
    final email = user.email ?? state.email;
    final isAdmin = user.isAdmin;
    final prefs = await SharedPreferences.getInstance();
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(_authUserIdKey, userId);
    }
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_authEmailKey, email);
    }
    await prefs.setBool(_authIsAdminKey, isAdmin);
    state = AuthState(
      token: token,
      userId: userId,
      email: email,
      expiresAt: state.expiresAt,
      isAdmin: isAdmin,
    );
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await _readStoredToken(prefs);
      final userId = prefs.getString(_authUserIdKey);
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
          userId: userId,
          email: email,
          expiresAt: expiresAt,
          isAdmin: isAdmin,
        );
      } else {
        if (kDebugMode && kIsWeb) {
          final debugEmail = email ?? _devAuthEmail;
          final debugExpiresAt = _jwtExpiresAt(_debugWebPreviewToken);
          ref.read(apiAuthTokenProvider.notifier).set(_debugWebPreviewToken);
          ref.read(apiClientProvider).setToken(_debugWebPreviewToken);
          state = AuthState(
            token: _debugWebPreviewToken,
            userId: userId ?? 'debug-web-preview',
            email: debugEmail,
            expiresAt: debugExpiresAt,
            isAdmin: true,
          );
          return;
        }
        ref.read(apiAuthTokenProvider.notifier).set(null);
        state = AuthState(userId: userId, email: email);
      }
    } catch (error) {
      ref.read(apiAuthTokenProvider.notifier).set(null);
      state = AuthState(error: error.toString());
    }
  }

  Future<void> _persistSession({
    required AuthSession session,
  }) async {
    final token = session.token;
    final userId = session.user.id;
    final email = session.user.email;
    final isAdmin = session.user.isAdmin;
    final prefs = await SharedPreferences.getInstance();
    await _authSecureStorage.write(key: _authTokenKey, value: token);
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(_authUserIdKey, userId);
    }
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_authEmailKey, email);
    }
    await prefs.setBool(_authIsAdminKey, isAdmin);
    ref.read(apiAuthTokenProvider.notifier).set(token);
    ref.read(apiClientProvider).setToken(token);
    state = AuthState(
      token: token,
      userId: userId,
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
    final userId = prefs.getString(_authUserIdKey) ?? state.userId;
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
    await prefs.remove(_authUserIdKey);
    await prefs.remove(_authEmailKey);
    await prefs.remove(_authIsAdminKey);
    ref.read(apiAuthTokenProvider.notifier).set(null);
    ref.read(apiClientProvider).clearToken();
    state = AuthState(
      userId: userId,
      email: email,
      expiresAt: expiresAt,
      error: error,
    );
  }

  Future<String?> _readStoredToken(SharedPreferences prefs) async {
    try {
      final secureToken = await _authSecureStorage
          .read(key: _authTokenKey)
          .timeout(_secureStorageReadTimeout);
      return secureToken != null && secureToken.isNotEmpty
          ? secureToken
          : null;
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'auth',
        message: 'Failed to read secure token within the restore window.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
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
