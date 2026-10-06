import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Dio interceptor that intercepts requests and returns fake responses
/// without making any real HTTP calls.
class _FakeApiInterceptor extends Interceptor {
  final Map<String, _FakeResponse> _responses = {};

  void onGet(String path, Object? data, {int statusCode = 200}) {
    _responses['GET:$path'] = _FakeResponse(data, statusCode);
  }

  void onPost(String path, Object? data, {int statusCode = 200}) {
    _responses['POST:$path'] = _FakeResponse(data, statusCode);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = '${options.method}:${options.path}';
    final fake = _responses[key];
    if (fake != null) {
      handler.resolve(Response(
        requestOptions: options,
        data: fake.data,
        statusCode: fake.statusCode,
      ));
      return;
    }
    handler.reject(DioException(
      requestOptions: options,
      error: 'No fake handler for $key',
      type: DioExceptionType.unknown,
    ));
  }
}

class _FakeResponse {
  const _FakeResponse(this.data, this.statusCode);
  final Object? data;
  final int statusCode;
}

ApiClient _createTestClient(_FakeApiInterceptor interceptor) {
  final client = ApiClient(baseUrl: 'http://test-server');
  client.addInterceptor(interceptor);
  return client;
}

void main() {
  group('ApiClient', () {
    group('health', () {
      test('returns server health data', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor
            .onGet('/api/v1/health', {'status': 'ok', 'version': '1.2.3'});
        final client = _createTestClient(interceptor);

        final result = await client.health();

        expect(result['status'], 'ok');
        expect(result['version'], '1.2.3');
      });

      test('throws on null response', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/health', null);
        final client = _createTestClient(interceptor);

        expect(() => client.health(), throwsStateError);
      });
    });

    group('login', () {
      test('returns user data and sets token', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onPost('/api/v1/auth/login', {
          'access_token': 'test-jwt-token-123',
          'user': {'id': 'u1', 'email': 'test@example.com'},
        });
        final client = _createTestClient(interceptor);

        final result = await client.login(
          email: 'test@example.com',
          password: 'secret',
        );

        expect(result.token, 'test-jwt-token-123');
        expect(client.authorizationHeader, 'Bearer test-jwt-token-123');
      });
    });

    group('register', () {
      test('returns user data and sets token', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onPost('/api/v1/auth/register', {
          'access_token': 'new-token-456',
          'user': {'id': 'u2', 'email': 'new@example.com'},
        });
        final client = _createTestClient(interceptor);

        final result = await client.register(
          email: 'new@example.com',
          password: 'secret123',
          displayName: 'Test User',
        );

        expect(result.token, 'new-token-456');
        expect(client.authorizationHeader, 'Bearer new-token-456');
      });
    });

    group('currentUser', () {
      test('returns user profile', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/auth/me', {
          'id': 'u1',
          'email': 'test@example.com',
          'display_name': 'Test User',
        });
        final client = _createTestClient(interceptor);

        final result = await client.currentUser();

        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
      });

      test('throws on null response', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/auth/me', null);
        final client = _createTestClient(interceptor);

        expect(() => client.currentUser(), throwsStateError);
      });
    });

    group('token management', () {
      test('setToken sets Authorization header', () {
        final client = ApiClient(baseUrl: 'http://test');
        expect(client.authorizationHeader, isNull);

        client.setToken('my-token');
        expect(client.authorizationHeader, 'Bearer my-token');
      });

      test('clearToken removes Authorization header', () {
        final client = ApiClient(baseUrl: 'http://test');
        client.setToken('my-token');
        expect(client.authorizationHeader, 'Bearer my-token');

        client.clearToken();
        expect(client.authorizationHeader, isNull);
      });
    });

    group('search', () {
      test('returns search results', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/search', {
          'items': [
            {'id': 'item-1', 'title': 'Batman #1', 'kind': 'comic'},
            {'id': 'item-2', 'title': 'Batman #2', 'kind': 'comic'},
          ],
          'has_more': false,
          'next_offset': null,
        });
        final client = _createTestClient(interceptor);

        final results = await client.search('Batman', kind: 'comic');

        expect(results, hasLength(2));
        expect(results[0]['title'], 'Batman #1');
        expect(results[1]['title'], 'Batman #2');
      });

      test('returns compact typed search hits', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/search', {
          'items': [
            {
              'id': 'movie-1',
              'title': 'Arrival',
              'kind': 'movie',
              'summary': 'A linguist meets visitors.',
              'image_url': 'https://example.test/arrival.jpg',
              'payload': {'not': 'part of a search hit'},
            },
          ],
          'has_more': false,
          'next_offset': null,
        });
        final client = _createTestClient(interceptor);

        final hits = await client.searchHits(
          'Arrival',
          kind: CatalogMediaKind.movie,
        );

        expect(hits, hasLength(1));
        expect(hits.single.title, 'Arrival');
        expect(hits.single.kind, CatalogMediaKind.movie);
        expect(hits.single.ref.id, 'movie-1');
        expect(hits.single.toJson().containsKey('payload'), isFalse);
      });
    });

    group('catalog transport dtos', () {
      test('returns flattened Catalog Item JSON and preserves kind payload',
          () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/metadata/books/items/item-1', {
          'id': 'item-1',
          'kind': 'book',
          'title': 'The Sample Book',
          'release_date': '2024-01-02T03:04:05Z',
          'cover_image_url': 'https://example.com/cover.jpg',
          'thumbnail_image_url': 'https://example.com/thumb.jpg',
          'barcode': '1234567890',
          'tracks': [
            {'title': 'Track 1', 'position': 1, 'duration_seconds': 180},
          ],
        });
        final client = _createTestClient(interceptor);

        final dto = await client.getCatalogItemJson(
          kind: CatalogMediaKind.book,
          id: 'item-1',
        );

        expect(dto['id'], 'item-1');
        expect(dto['title'], 'The Sample Book');
        expect(dto['tracks'], hasLength(1));
        expect(dto['barcode'], '1234567890');
        expect(dto['kind'], 'book');
      });

      test('returns kind-specific typed metadata dto helpers', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/metadata/games/items/game-1', {
          'id': 'game-1',
          'kind': 'game',
          'title': 'Zelda',
          'platforms': ['Switch'],
        });
        interceptor.onGet('/api/v1/metadata/boardgames/items/bg-1', {
          'id': 'bg-1',
          'kind': 'boardgame',
          'title': 'Catan',
          'barcode': '123',
        });
        final client = _createTestClient(interceptor);

        final game = await client.getCatalogItemJson(
          kind: CatalogMediaKind.game,
          id: 'game-1',
        );
        final boardgame = await client.getCatalogItemJson(
          kind: CatalogMediaKind.boardgame,
          id: 'bg-1',
        );

        expect(game['platforms'], ['Switch']);
        expect(boardgame['title'], 'Catan');
      });

      test('returns typed search dtos', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/search', {
          'items': [
            {'id': 'item-1', 'title': 'Batman #1', 'kind': 'comic'},
            {'id': 'item-2', 'title': 'Batman #2', 'kind': 'comic'},
          ],
          'has_more': false,
          'next_offset': null,
        });
        final client = _createTestClient(interceptor);

        final results = await client.searchMetadata(
          const MetadataSearchQuery(query: 'Batman'),
        );

        expect(results, hasLength(2));
        expect(results.first['kind'], 'comic');
        expect(results.first['title'], 'Batman #1');
      });

      test('uses flattened Catalog Item routes for each kind', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/api/v1/metadata/comics/items/comic-1', {
          'id': 'comic-1',
          'kind': 'comic',
          'title': 'Saga',
        });
        interceptor.onGet('/api/v1/metadata/anime/items/anime-1', {
          'id': 'anime-1',
          'kind': 'anime',
          'title': 'Naruto',
        });
        interceptor.onGet('/api/v1/metadata/movies/items/movie-1', {
          'id': 'movie-1',
          'kind': 'movie',
          'title': 'Alien',
        });
        interceptor.onGet('/api/v1/metadata/tv/items/tv-1', {
          'id': 'tv-1',
          'kind': 'tv',
          'title': 'Breaking Bad',
        });
        final client = _createTestClient(interceptor);

        for (final (kind, id, title) in [
          (CatalogMediaKind.comic, 'comic-1', 'Saga'),
          (CatalogMediaKind.anime, 'anime-1', 'Naruto'),
          (CatalogMediaKind.movie, 'movie-1', 'Alien'),
          (CatalogMediaKind.tv, 'tv-1', 'Breaking Bad'),
        ]) {
          final item = await client.getCatalogItemJson(kind: kind, id: id);
          expect(item['id'], id);
          expect(item['title'], title);
        }
      });
    });

    group('baseUrl', () {
      test('trims whitespace from base URL', () {
        final client = ApiClient(baseUrl: '  http://test-server  ');
        expect(client.baseUrl, 'http://test-server');
      });

      test('defaults to localhost', () {
        final client = ApiClient();
        expect(client.baseUrl, 'http://127.0.0.1:8010');
      });
    });
  });
}
