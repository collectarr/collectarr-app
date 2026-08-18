import 'dart:io';
import 'dart:typed_data';

import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockHttpAdapter implements HttpClientAdapter {
  _MockHttpAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('provider_image_cache_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ProviderImageCache', () {
    test(
        'fetches and caches image on cache miss and serves cache hit afterwards',
        () async {
      var networkCalls = 0;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        networkCalls++;
        expect(options.path, 'https://example.com/cover.jpg');
        return ResponseBody.fromBytes(
          Uint8List.fromList([1, 2, 3, 4, 5]),
          200,
          headers: {
            Headers.contentTypeHeader: ['image/jpeg'],
          },
        );
      });

      final cache = ProviderImageCache(cacheDir: tempDir, dio: dio);
      const ref = ProviderImageRef(
        provider: 'tmdb',
        url: 'https://example.com/cover.jpg',
        attribution: 'TMDb',
      );

      // Initial state: not cached
      final initial = await cache.getCachedImage(ref);
      expect(initial, isNull);

      // Fetch and cache
      final file = await cache.fetchAndCache(ref);
      expect(networkCalls, 1);
      expect(await file.exists(), isTrue);
      expect(await file.length(), 5);

      // Cache hit: subsequent lookup does not call network
      final hit = await cache.getCachedImage(ref);
      expect(hit, isNotNull);
      expect(await hit!.readAsBytes(), [1, 2, 3, 4, 5]);

      // fetchAndCache with forceRefresh=false returns cached file without calling network
      final cachedAgain = await cache.fetchAndCache(ref);
      expect(networkCalls, 1);
      expect(cachedAgain.path, file.path);
    });

    test('forwards custom headers on authenticated image downloads', () async {
      String? sentAuthHeader;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        sentAuthHeader = options.headers['Authorization']?.toString();
        return ResponseBody.fromBytes(
          Uint8List.fromList([10, 20]),
          200,
          headers: {
            Headers.contentTypeHeader: ['image/png'],
          },
        );
      });

      final cache = ProviderImageCache(cacheDir: tempDir, dio: dio);
      const ref = ProviderImageRef(
        provider: 'igdb',
        url: 'https://images.igdb.com/igdb/image/upload/t_cover_big/co123.png',
        headers: {'Authorization': 'Bearer test-token-123'},
      );

      final file = await cache.fetchAndCache(ref);
      expect(sentAuthHeader, 'Bearer test-token-123');
      expect(await file.exists(), isTrue);
    });

    test('prunes expired cache items', () async {
      final dio = Dio();
      final cache = ProviderImageCache(cacheDir: tempDir, dio: dio);

      final expiredRef = ProviderImageRef(
        provider: 'test',
        url: 'https://example.com/expired.jpg',
        expiresAt:
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      );

      final validRef = ProviderImageRef(
        provider: 'test',
        url: 'https://example.com/valid.jpg',
        expiresAt:
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      );

      await cache.putBytes(expiredRef, Uint8List.fromList([1, 2, 3]));
      await cache.putBytes(validRef, Uint8List.fromList([4, 5, 6, 7]));

      expect(await cache.getCacheSizeBytes(), greaterThan(0));

      final pruned = await cache.pruneExpired();
      expect(pruned, 1);

      expect(await cache.getCachedImage(expiredRef), isNull);
      expect(await cache.getCachedImage(validRef), isNotNull);
    });

    test('clearCache removes all stored files', () async {
      final dio = Dio();
      final cache = ProviderImageCache(cacheDir: tempDir, dio: dio);

      const ref = ProviderImageRef(
        provider: 'openlibrary',
        url: 'https://covers.openlibrary.org/b/id/123-L.jpg',
      );

      await cache.putBytes(ref, Uint8List.fromList([1, 2, 3, 4]));
      expect(await cache.getCacheSizeBytes(), greaterThan(0));

      await cache.clearCache();
      expect(await cache.getCacheSizeBytes(), 0);
      expect(await cache.getCachedImage(ref), isNull);
    });
  });
}
