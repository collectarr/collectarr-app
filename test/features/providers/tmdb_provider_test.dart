import 'dart:convert';
import 'dart:io';

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
  group('TMDbProvider', () {
    test('exposes correct descriptor metadata', () {
      final provider = TMDbProvider();
      expect(provider.name, 'tmdb');
      expect(provider.descriptor.displayName, 'TMDb');
      expect(provider.descriptor.kind, 'movie');
      expect(provider.descriptor.supportedKinds,
          containsAll(['movie', 'tv', 'anime']));
      expect(provider.descriptor.requiresUserKey, isTrue);
      expect(provider.isConfigured, isFalse);
      expect(provider.descriptor.rateLimit, '40 req/10s');
    });

    test('throws ProviderAuthException when unconfigured', () async {
      final provider = TMDbProvider();
      expect(() => provider.search('Fight Club'),
          throwsA(isA<ProviderAuthException>()));
    });

    test(
        'search queries search/movie endpoint with bearer token and formats candidates',
        () async {
      String? sentAuthHeader;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        sentAuthHeader = options.headers['Authorization']?.toString();
        expect(options.path, '/search/movie');
        expect(options.queryParameters['query'], 'Fight Club');
        return ResponseBody.fromString(
          jsonEncode({
            'results': [
              {
                'id': 550,
                'title': 'Fight Club',
                'release_date': '1999-10-15',
                'original_language': 'en',
                'poster_path': '/bptfVGEQuv6vDTIMVCHjJ9Dz8PX.jpg',
              }
            ]
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      const creds = TmdbCredentials(readAccessToken: 'tmdb-jwt-token-xyz');
      final client = ProviderHttpClient(
        provider: 'tmdb',
        baseUrl: 'https://api.themoviedb.org/3',
        dio: dio,
      );
      final provider = TMDbProvider(credentials: creds, httpClient: client);
      expect(provider.isConfigured, isTrue);

      final results = await provider.search('Fight Club');
      expect(sentAuthHeader, 'Bearer tmdb-jwt-token-xyz');
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'tmdb');
      expect(item.providerItemId, 'movie:550');
      expect(item.title, 'Fight Club');
      expect(item.kind, 'movie');
      expect(item.summary, '1999-10-15 · en');
      expect(item.imageUrl,
          'https://image.tmdb.org/t/p/w500/bptfVGEQuv6vDTIMVCHjJ9Dz8PX.jpg');
    });

    test('fetchItem fetches movie details and outputs standardized envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path, '/movie/550');
        return ResponseBody.fromString(
          jsonEncode({
            'id': 550,
            'title': 'Fight Club',
            'overview':
                'A ticking-time-bomb insomniac and a slippery soap salesman channel raw male aggression into a shocking new form of therapy.',
            'runtime': 139,
            'vote_average': 8.4,
            'poster_path': '/bptfVGEQuv6vDTIMVCHjJ9Dz8PX.jpg',
            'genres': [
              {'name': 'Drama'},
              {'name': 'Thriller'},
            ],
            'production_companies': [
              {'name': '20th Century Fox'}
            ],
            'external_ids': {
              'imdb_id': 'tt0137523',
            },
            'credits': {
              'crew': [
                {'name': 'David Fincher', 'job': 'Director'},
              ],
              'cast': [
                {'name': 'Brad Pitt'},
                {'name': 'Edward Norton'},
              ],
            }
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      const creds = TmdbCredentials(apiKey: 'raw-api-key');
      final client = ProviderHttpClient(
        provider: 'tmdb',
        baseUrl: 'https://api.themoviedb.org/3',
        dio: dio,
      );
      final provider = TMDbProvider(credentials: creds, httpClient: client);

      final envelope = await provider.fetchItem('550');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'tmdb');
      expect(envelope.providerItemId, '550');
      expect(envelope.kind, 'movie');
      expect(envelope.normalized['title'], 'Fight Club');
      expect(envelope.normalized['runtime_minutes'], 139);
      expect(envelope.normalized['publisher'], '20th Century Fox');
      expect(envelope.normalized['audience_rating'], '8.4');
      expect(envelope.normalized['genres'], containsAll(['Drama', 'Thriller']));
      expect(envelope.normalized['provider_ids']['tmdb'], '550');
      expect(envelope.normalized['provider_ids']['imdb'], 'tt0137523');
      expect(envelope.normalized['creators'], hasLength(3));
      expect(envelope.images, hasLength(1));
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for TMDb', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final tmdbFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'tmdb',
        orElse: () => null,
      );
      expect(tmdbFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(tmdbFixtureRaw as Map),
      );

      final provider = TMDbProvider();
      final normalized = provider.normalize({
        'id': 550,
        'title': 'Fight Club',
        'overview':
            'A ticking-time-bomb insomniac and a slippery soap salesman channel raw male aggression into a shocking new form of therapy.',
        'runtime': 139,
        'vote_average': 8.4,
        'poster_path': '/bptfVGEQuv6vDTIMVCHjJ9Dz8PX.jpg',
        'genres': [
          {'name': 'Drama'},
          {'name': 'Thriller'},
        ],
        'production_companies': [
          {'name': '20th Century Fox'}
        ],
        'external_ids': {
          'imdb_id': 'tt0137523',
        },
        'credits': {
          'crew': [
            {'name': 'David Fincher', 'job': 'Director'},
          ],
          'cast': [
            {'name': 'Brad Pitt'},
            {'name': 'Edward Norton'},
          ],
        }
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['runtime_minutes'],
          goldenEnvelope.normalized['runtime_minutes']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(normalized['genres'], goldenEnvelope.normalized['genres']);
      expect(normalized['audience_rating'],
          goldenEnvelope.normalized['audience_rating']);
      expect(normalized['provider_ids']['tmdb'],
          goldenEnvelope.normalized['provider_ids']['tmdb']);
      expect(normalized['provider_ids']['imdb'],
          goldenEnvelope.normalized['provider_ids']['imdb']);
      expect(normalized['creators'][0]['name'],
          goldenEnvelope.normalized['creators'][0]['name']);
      expect(normalized['creators'][0]['role'],
          goldenEnvelope.normalized['creators'][0]['role']);
    });
  });
}
