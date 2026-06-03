import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(setUpSecureStorageMock);

  test('restored auth token is applied to rebuilt api clients', () async {
    final token = _jwtExpiringAt(DateTime.now().toUtc().add(
          const Duration(hours: 1),
        ));
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': token,
      'collectarr.auth.email': 'user@example.com',
      'collectarr.auth.is_admin': true,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(authControllerProvider);
    await _waitForAuthRestore(container);

    expect(container.read(authControllerProvider).isAuthenticated, isTrue);
    expect(container.read(authControllerProvider).isAdmin, isTrue);
    expect(
      container.read(apiClientProvider).authorizationHeader,
      'Bearer $token',
    );

    await container.read(connectionSettingsProvider.notifier).save(
          metadataBaseUrl: 'http://metadata.local:8010/',
          syncBaseUrl: 'http://sync.local:8020/',
          syncKey: 'sync-key',
        );

    final rebuiltClient = container.read(apiClientProvider);
    expect(rebuiltClient.baseUrl, 'http://metadata.local:8010');
    expect(rebuiltClient.authorizationHeader, 'Bearer $token');
  });

  test('expired restored auth token is cleared', () async {
    final token = _jwtExpiringAt(DateTime.now().toUtc().subtract(
          const Duration(minutes: 1),
        ));
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': token,
      'collectarr.auth.email': 'user@example.com',
      'collectarr.auth.is_admin': true,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(authControllerProvider);
    await _waitForAuthRestore(container);

    final auth = container.read(authControllerProvider);
    expect(auth.isAuthenticated, isFalse);
    expect(auth.isExpired, isTrue);
    expect(auth.error, contains('Session expired'));
    expect(container.read(apiAuthTokenProvider), isNull);
    expect(container.read(apiClientProvider).authorizationHeader, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('collectarr.auth.token'), isNull);
    expect(prefs.getString('collectarr.auth.email'), 'user@example.com');
    expect(prefs.getBool('collectarr.auth.is_admin'), isNull);
  });

  test('server reset auth rejection clears restored token', () async {
    final token = _jwtExpiringAt(DateTime.now().toUtc().add(
          const Duration(hours: 1),
        ));
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': token,
      'collectarr.auth.email': 'user@example.com',
      'collectarr.auth.is_admin': true,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(authControllerProvider);
    await _waitForAuthRestore(container);

    final cleared = await container
        .read(authControllerProvider.notifier)
        .clearSessionIfRejected(_authRejectedByServerReset());

    expect(cleared, isTrue);
    final auth = container.read(authControllerProvider);
    expect(auth.isAuthenticated, isFalse);
    expect(auth.email, 'user@example.com');
    expect(auth.error, contains('session reset'));
    expect(container.read(apiAuthTokenProvider), isNull);
    expect(container.read(apiClientProvider).authorizationHeader, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('collectarr.auth.token'), isNull);
    expect(prefs.getString('collectarr.auth.email'), 'user@example.com');
    expect(prefs.getBool('collectarr.auth.is_admin'), isNull);
  });

  test('missing bearer token is not treated as stale local session', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(authControllerProvider);
    await _waitForAuthRestore(container);

    final cleared = await container
        .read(authControllerProvider.notifier)
        .clearSessionIfRejected(_missingBearerToken());

    expect(cleared, isFalse);
    expect(container.read(authControllerProvider).error, isNull);
  });

  test('login stores admin permission from token response', () async {
    SharedPreferences.setMockInitialValues({});
    final token = _jwtExpiringAt(DateTime.now().toUtc().add(
          const Duration(hours: 1),
        ));
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(_AdminLoginClient(token))
      ],
    );
    addTearDown(container.dispose);

    container.read(authControllerProvider);
    await _waitForAuthRestore(container);

    await container
        .read(authControllerProvider.notifier)
        .login('admin@example.com', 'password123');

    final auth = container.read(authControllerProvider);
    expect(auth.isAuthenticated, isTrue);
    expect(auth.email, 'admin@example.com');
    expect(auth.isAdmin, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('collectarr.auth.is_admin'), isTrue);
  });

  test('login falls back to shared preferences when secure storage fails',
      () async {
    SharedPreferences.setMockInitialValues({});
    final token = _jwtExpiringAt(DateTime.now().toUtc().add(
          const Duration(hours: 1),
        ));
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(_AdminLoginClient(token)),
      ],
    );
    addTearDown(() {
      clearSecureStorageFailures();
      container.dispose();
    });

    container.read(authControllerProvider);
    await _waitForAuthRestore(container);
    failSecureStorageWrites();

    await container
        .read(authControllerProvider.notifier)
        .login('fallback@example.com', 'password123');

    final auth = container.read(authControllerProvider);
    expect(auth.isAuthenticated, isTrue);
    expect(auth.email, 'fallback@example.com');
    expect(container.read(apiAuthTokenProvider), token);
    expect(container.read(apiClientProvider).authorizationHeader, 'Bearer $token');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('collectarr.auth.token'), token);
    expect(prefs.getString('collectarr.auth.email'), 'fallback@example.com');
    expect(prefs.getBool('collectarr.auth.is_admin'), isTrue);
  });

  test('restore falls back to shared preferences when secure storage read hangs',
      () async {
    final token = _jwtExpiringAt(DateTime.now().toUtc().add(
          const Duration(hours: 1),
        ));
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': token,
      'collectarr.auth.email': 'user@example.com',
      'collectarr.auth.is_admin': true,
    });
    hangSecureStorageReads();
    final container = ProviderContainer();
    addTearDown(() {
      clearSecureStorageFailures();
      container.dispose();
    });

    container.read(authControllerProvider);
    await _waitForAuthRestore(
      container,
      timeout: const Duration(seconds: 3),
    );

    final auth = container.read(authControllerProvider);
    expect(auth.isRestoring, isFalse);
    expect(auth.isAuthenticated, isTrue);
    expect(auth.email, 'user@example.com');
    expect(container.read(apiAuthTokenProvider), token);
  });

  test('login maps rejected credentials to a friendly error', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(_RejectedLoginClient())],
    );
    addTearDown(container.dispose);

    container.read(authControllerProvider);
    await _waitForAuthRestore(container);

    await container
        .read(authControllerProvider.notifier)
        .login('user@example.com', 'bad-password');

    final auth = container.read(authControllerProvider);
    expect(auth.isAuthenticated, isFalse);
    expect(auth.error, contains('Invalid'));
  });
}

Future<void> _waitForAuthRestore(
  ProviderContainer container, {
  Duration timeout = const Duration(milliseconds: 250),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (!container.read(authControllerProvider).isRestoring) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Auth restore did not finish within $timeout.');
}

String _jwtExpiringAt(DateTime expiresAt) {
  final encodedHeader = _base64UrlJson({'alg': 'none', 'typ': 'JWT'});
  final encodedPayload = _base64UrlJson({
    'sub': '00000000-0000-0000-0000-000000000001',
    'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
  });
  return '$encodedHeader.$encodedPayload.signature';
}

String _base64UrlJson(Map<String, Object> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}

class _RejectedLoginClient extends ApiClient {
  _RejectedLoginClient() : super(baseUrl: 'http://metadata.local');

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final requestOptions = RequestOptions(path: '/auth/login');
    throw DioException(
      requestOptions: requestOptions,
      response: Response<void>(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
    );
  }
}

DioException _authRejectedByServerReset() {
  final requestOptions = RequestOptions(path: '/metadata/providers/search');
  return DioException(
    requestOptions: requestOptions,
    response: Response<Map<String, dynamic>>(
      requestOptions: requestOptions,
      statusCode: 401,
      data: {
        'detail': 'User not found',
        'code': 'user_not_found',
      },
    ),
  );
}

DioException _missingBearerToken() {
  final requestOptions = RequestOptions(path: '/metadata/providers/search');
  return DioException(
    requestOptions: requestOptions,
    response: Response<Map<String, dynamic>>(
      requestOptions: requestOptions,
      statusCode: 401,
      data: {
        'detail': 'Missing bearer token',
        'code': 'missing_bearer_token',
      },
    ),
  );
}

class _AdminLoginClient extends ApiClient {
  _AdminLoginClient(this.token) : super(baseUrl: 'http://metadata.local');

  final String token;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return {
      'access_token': token,
      'token_type': 'bearer',
      'user': {
        'id': '00000000-0000-0000-0000-000000000001',
        'email': email,
        'display_name': null,
        'is_admin': true,
      },
    };
  }
}
