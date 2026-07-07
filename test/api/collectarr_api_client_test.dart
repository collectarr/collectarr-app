import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
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
        interceptor.onGet('/health', {'status': 'ok', 'version': '1.2.3'});
        final client = _createTestClient(interceptor);

        final result = await client.health();

        expect(result['status'], 'ok');
        expect(result['version'], '1.2.3');
      });

      test('throws on null response', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/health', null);
        final client = _createTestClient(interceptor);

        expect(() => client.health(), throwsStateError);
      });
    });

    group('login', () {
      test('returns user data and sets token', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onPost('/auth/login', {
          'access_token': 'test-jwt-token-123',
          'user': {'id': 'u1', 'email': 'test@example.com'},
        });
        final client = _createTestClient(interceptor);

        final result = await client.login(
          email: 'test@example.com',
          password: 'secret',
        );

        expect(result['access_token'], 'test-jwt-token-123');
        expect(client.authorizationHeader, 'Bearer test-jwt-token-123');
      });
    });

    group('register', () {
      test('returns user data and sets token', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onPost('/auth/register', {
          'access_token': 'new-token-456',
          'user': {'id': 'u2', 'email': 'new@example.com'},
        });
        final client = _createTestClient(interceptor);

        final result = await client.register(
          email: 'new@example.com',
          password: 'secret123',
          displayName: 'Test User',
        );

        expect(result['access_token'], 'new-token-456');
        expect(client.authorizationHeader, 'Bearer new-token-456');
      });
    });

    group('currentUser', () {
      test('returns user profile', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/auth/me', {
          'id': 'u1',
          'email': 'test@example.com',
          'display_name': 'Test User',
        });
        final client = _createTestClient(interceptor);

        final result = await client.currentUser();

        expect(result['email'], 'test@example.com');
        expect(result['display_name'], 'Test User');
      });

      test('throws on null response', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/auth/me', null);
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
        interceptor.onGet('/search', [
          {'id': 'item-1', 'title': 'Batman #1', 'kind': 'comic'},
          {'id': 'item-2', 'title': 'Batman #2', 'kind': 'comic'},
        ]);
        final client = _createTestClient(interceptor);

        final results = await client.search('Batman', kind: 'comic');

        expect(results, hasLength(2));
        expect(results[0]['title'], 'Batman #1');
        expect(results[1]['title'], 'Batman #2');
      });
    });

    group('catalog transport dtos', () {
      test('returns typed metadata response and preserves raw payload',
          () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/metadata/books/works/item-1', {
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

        final dto =
            await client.getTypedMetadataItem(kind: 'book', id: 'item-1');

        expect(dto.id, 'item-1');
        expect(dto.title, 'The Sample Book');
        expect(dto, isA<BookWorkDto>());
        expect(dto.raw['tracks'], hasLength(1));
        expect(dto.raw['barcode'], '1234567890');

        expect(dto.kind, 'book');
        expect(dto.title, 'The Sample Book');
      });

      test('returns kind-specific typed metadata dto helpers', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/metadata/games/works/game-1', {
          'id': 'game-1',
          'kind': 'game',
          'title': 'Zelda',
          'platforms': ['Switch', 'switch'],
        });
        interceptor.onGet('/metadata/boardgames/editions/bg-1', {
          'id': 'bg-1',
          'kind': 'boardgame',
          'title': 'Catan',
          'barcode': '123',
        });
        final client = _createTestClient(interceptor);

        final game = await client.getGameWorkDto('game-1');
        final boardgame = await client.getBoardGameEditionDto('bg-1');

        expect(game.platforms, ['Switch']);
        expect(boardgame.title, 'Catan');
      });

      test('returns typed search dtos', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/search', [
          {'id': 'item-1', 'title': 'Batman #1', 'kind': 'comic'},
          {'id': 'item-2', 'title': 'Batman #2', 'kind': 'comic'},
        ]);
        final client = _createTestClient(interceptor);

        final results = await client.searchMetadata(
          const MetadataSearchQuery(query: 'Batman'),
        );

        expect(results, hasLength(2));
        expect(results.first['kind'], 'comic');
        expect(results.first['title'], 'Batman #1');
      });

      test('uses typed routes for comic manga anime movie and tv', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/metadata/comics/works/comic-1', {
          'id': 'comic-1',
          'title': 'Saga',
          'issues': <dynamic>[],
        });
        interceptor.onGet('/metadata/manga/works/manga-1', {
          'id': 'manga-1',
          'title': 'Berserk',
          'chapters': <dynamic>[],
        });
        interceptor.onGet('/metadata/anime/series/anime-1', {
          'id': 'anime-1',
          'title': 'Naruto',
          'episodes': <dynamic>[],
        });
        interceptor.onGet('/metadata/movies/works/movie-1', {
          'id': 'movie-1',
          'title': 'Alien',
          'releases': <dynamic>[],
        });
        interceptor.onGet('/metadata/tv/series/tv-1', {
          'id': 'tv-1',
          'title': 'Breaking Bad',
          'seasons': <dynamic>[],
        });
        final client = _createTestClient(interceptor);

        expect(await client.getTypedMetadataItem(kind: 'comic', id: 'comic-1'),
            isA<ComicWorkDto>());
        expect(await client.getTypedMetadataItem(kind: 'manga', id: 'manga-1'),
            isA<MangaWorkDto>());
        expect(await client.getTypedMetadataItem(kind: 'anime', id: 'anime-1'),
            isA<AnimeSeriesDto>());
        expect(await client.getTypedMetadataItem(kind: 'movie', id: 'movie-1'),
            isA<MovieWorkDto>());
        expect(await client.getTypedMetadataItem(kind: 'tv', id: 'tv-1'),
            isA<TvSeriesDto>());
      });

      test('uses typed volume and TV season routes when kind is known',
          () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onGet('/metadata/manga/works/manga-1', {
          'id': 'manga-1',
          'title': 'Berserk',
          'chapters': [
            {'chapter_number': 1, 'chapter_title': 'Black Swordsman'},
          ],
        });
        interceptor.onGet('/metadata/tv/series/tv-1/seasons', [
          {
            'id': 'season-1',
            'series_id': 'tv-1',
            'season_number': 1,
            'episode_count': 1,
            'description': 'Season 1',
            'episodes': [
              {
                'id': 'episode-1',
                'season_id': 'season-1',
                'episode_number': 1,
                'episode_title': 'Pilot',
              }
            ],
          }
        ]);
        interceptor.onGet('/metadata/tv/seasons/season-1/episodes', [
          {
            'id': 'episode-1',
            'season_id': 'season-1',
            'episode_number': 1,
            'episode_title': 'Pilot',
          }
        ]);
        interceptor.onGet('/metadata/anime/series/anime-1', {
          'id': 'anime-1',
          'title': 'Naruto',
          'episodes': [
            {
              'episode_number': 1,
              'episode_title': 'Enter Naruto Uzumaki!',
            }
          ],
        });
        final client = _createTestClient(interceptor);

        expect(
          await client.getItemVolumes('manga-1', kind: 'manga'),
          hasLength(1),
        );
        expect(
          await client.getTvSeriesSeasonsDto('tv-1'),
          hasLength(1),
        );
        expect(
          await client.getTvSeasonEpisodesDto('season-1'),
          hasLength(1),
        );
      });

      test('uses typed edition creation route for books', () async {
        final interceptor = _FakeApiInterceptor();
        interceptor.onPost('/metadata/books/works/book-1/editions', {
          'id': 'edition-1',
          'title': 'Paperback',
          'format': 'paperback',
        });
        final client = _createTestClient(interceptor);

        final edition = await client.createBookEdition(
          'book-1',
          title: 'Paperback',
        );

        expect(edition.id, 'edition-1');
        expect(edition.title, 'Paperback');
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
