import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_account.dart';
import 'package:collectarr_app/core/sync/sync_error_message.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sync connection errors explain recovery without exposing exceptions',
      () {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.badCertificate,
      DioExceptionType.unknown,
    ]) {
      final error = DioException(
          requestOptions: RequestOptions(path: '/health'),
          type: type,
          message: 'Private transport details');
      expect(syncErrorMessage(error), isNot(contains('DioException')));
      expect(syncErrorMessage(error), isNot(contains('Private transport')));
    }
    expect(syncErrorMessage(const SyncAccountException('Sign in again.')),
        'Sign in again.');
  });

  test(
      'sync health check times out once when the service stops responding',
      () => _localHttp(() async {
            final server =
                await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
            addTearDown(() => server.close(force: true));
            var requests = 0;
            server.listen((request) => requests++);
            final client = CollectarrSyncClient(
                baseUrl: 'http://127.0.0.1:${server.port}', syncKey: 'test');
            final stopwatch = Stopwatch()..start();
            await expectLater(
                client.health(),
                throwsA(isA<DioException>().having((error) => error.type,
                    'type', DioExceptionType.receiveTimeout)));
            expect(requests, 1);
            expect(stopwatch.elapsed, lessThan(const Duration(seconds: 6)));
          }));

  test(
      'sync transfer still retries temporary server responses',
      () => _localHttp(() async {
            final server =
                await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
            addTearDown(() => server.close(force: true));
            var requests = 0;
            server.listen((request) async {
              requests++;
              request.response.statusCode = requests < 3 ? 503 : 200;
              request.response.headers.contentType = ContentType.json;
              request.response.write(jsonEncode({'ok': requests == 3}));
              await request.response.close();
            });
            final client = CollectarrSyncClient(
                baseUrl: 'http://127.0.0.1:${server.port}', syncKey: 'test');
            expect(await client.push(deviceId: 'test-device', changes: []),
                {'ok': true});
            expect(requests, 3);
          }));
}

Future<T> _localHttp<T>(Future<T> Function() action) =>
    HttpOverrides.runWithHttpOverrides(action, _LoopbackHttpOverrides());

class _LoopbackHttpOverrides extends HttpOverrides {}
