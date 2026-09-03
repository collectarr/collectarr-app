import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/json_test_helpers.dart';

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
  group('IGDBProvider', () {
    test('decodes native game payload models', () {
      final game = IgdbGame.fromJson({
        'id': 1942,
        'name': 'The Witcher 3: Wild Hunt',
        'summary': 'A role-playing game.',
        'storyline': 'Geralt searches for Ciri.',
        'first_release_date': 1431993600,
        'cover': {
          'id': 42,
          'url': '//images.igdb.com/igdb/image/upload/t_thumb/co1.jpg'
        },
        'genres': [
          {'id': 12, 'name': 'Role-playing (RPG)'},
        ],
        'involved_companies': [
          {
            'developer': true,
            'publisher': false,
            'company': {'id': 1, 'name': 'CD Projekt Red'},
          },
        ],
        'platforms': [
          {'id': 6, 'name': 'PC'},
        ],
        'game_modes': [
          {'id': 1, 'name': 'Single player'},
        ],
        'age_ratings': [
          {'rating': 18, 'category': 1},
        ],
        'total_rating': 92.5,
        'slug': 'the-witcher-3-wild-hunt',
      });

      expect(game.id, 1942);
      expect(game.name, 'The Witcher 3: Wild Hunt');
      expect(game.cover?.url, contains('co1.jpg'));
      expect(game.genres.single.name, 'Role-playing (RPG)');
      expect(game.involvedCompanies.single.company?.name, 'CD Projekt Red');
      expect(game.involvedCompanies.single.developer, isTrue);
      expect(game.platforms.single.name, 'PC');
      expect(game.gameModes.single.name, 'Single player');
      expect(game.ageRatings.single.rating, 18);
      expect(game.totalRating, 92.5);
      expect(game.toJson()['slug'], 'the-witcher-3-wild-hunt');
    });

    test('exposes correct descriptor metadata', () {
      final provider = IGDBProvider();
      expect(provider.name, 'igdb');
      expect(provider.descriptor.displayName, 'IGDB');
      expect(provider.descriptor.kind, 'game');
      expect(provider.descriptor.supportedKinds, contains('game'));
      expect(provider.descriptor.requiresUserKey, isTrue);
      expect(provider.isConfigured, isFalse);
      expect(provider.descriptor.rateLimit, '4 req/sec');
    });

    test('throws ProviderAuthException when unconfigured', () async {
      final provider = IGDBProvider();
      expect(() => provider.search('Witcher'),
          throwsA(isA<ProviderAuthException>()));
    });

    test(
        'search queries games endpoint with Apicalypse query and formats candidates',
        () async {
      String? sentClientId;
      String? sentAuthHeader;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        sentClientId = options.headers['Client-ID']?.toString();
        sentAuthHeader = options.headers['Authorization']?.toString();
        expect(options.path, '/games');
        return ResponseBody.fromString(
          jsonEncode([
            {
              'id': 1942,
              'name': 'The Witcher 3: Wild Hunt',
              'first_release_date': 1431993600,
              'cover': {
                'url': '//images.igdb.com/igdb/image/upload/t_thumb/co1wyy.jpg'
              },
              'platforms': [
                {'name': 'PC'},
                {'name': 'PlayStation 4'},
              ]
            }
          ]),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      const creds = IgdbCredentials(
          clientId: 'twitch-client-123',
          userAccessToken: 'igdb-access-token-456');
      final client = ProviderHttpClient(
        provider: 'igdb',
        baseUrl: 'https://api.igdb.com/v4',
        dio: dio,
      );
      final provider = IGDBProvider(credentials: creds, httpClient: client);
      expect(provider.isConfigured, isTrue);

      final results = await provider.search('Witcher 3');
      expect(sentClientId, 'twitch-client-123');
      expect(sentAuthHeader, 'Bearer igdb-access-token-456');
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'igdb');
      expect(item.providerItemId, '1942');
      expect(item.title, 'The Witcher 3: Wild Hunt');
      expect(item.kind, 'game');
      expect(item.summary, '2015-05-19 · PC, PlayStation 4');
      expect(item.imageUrl,
          'https://images.igdb.com/igdb/image/upload/t_cover_big/co1wyy.jpg');
    });

    test('fetchItem fetches game details and outputs standardized envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path, '/games');
        return ResponseBody.fromString(
          jsonEncode([
            {
              'id': 1942,
              'name': 'The Witcher 3: Wild Hunt',
              'slug': 'the-witcher-3-wild-hunt',
              'summary':
                  'The Witcher: Wild Hunt is a story-driven open world RPG set in a visually stunning fantasy universe.',
              'total_rating': 92.0,
              'cover': {
                'url': '//images.igdb.com/igdb/image/upload/t_thumb/co1wyy.jpg'
              },
              'genres': [
                {'name': 'Role-playing (RPG)'},
                {'name': 'Adventure'},
              ],
              'platforms': [
                {'name': 'PC'},
                {'name': 'PlayStation 4'},
                {'name': 'Xbox One'},
                {'name': 'Nintendo Switch'},
              ],
              'involved_companies': [
                {
                  'company': {'name': 'CD PROJEKT RED'},
                  'publisher': true,
                  'developer': true,
                }
              ]
            }
          ]),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      const creds = IgdbCredentials(
          clientId: 'twitch-client-123',
          userAccessToken: 'igdb-access-token-456');
      final client = ProviderHttpClient(
        provider: 'igdb',
        baseUrl: 'https://api.igdb.com/v4',
        dio: dio,
      );
      final provider = IGDBProvider(credentials: creds, httpClient: client);

      final envelope = await provider.fetchItem('1942');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'igdb');
      expect(envelope.providerItemId, '1942');
      expect(envelope.kind, 'game');
      expect(envelope.normalized['title'], 'The Witcher 3: Wild Hunt');
      expect(envelope.normalized['publisher'], 'CD PROJEKT RED');
      expect(envelope.normalized['audience_rating'], '92.0');
      expect(envelope.normalized['genres'],
          containsAll(['Role-playing (RPG)', 'Adventure']));
      expect(envelope.normalized['platforms'],
          containsAll(['PC', 'PlayStation 4', 'Xbox One', 'Nintendo Switch']));
      expect(envelope.images, hasLength(1));
      expect(envelope.images[0].url,
          'https://images.igdb.com/igdb/image/upload/t_cover_big/co1wyy.jpg');
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for IGDB', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final igdbFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'igdb',
        orElse: () => null,
      );
      expect(igdbFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(igdbFixtureRaw as Map),
      );

      final provider = IGDBProvider();
      final normalized = provider.normalize({
        'id': 1942,
        'name': 'The Witcher 3: Wild Hunt',
        'summary':
            'The Witcher: Wild Hunt is a story-driven open world RPG set in a visually stunning fantasy universe.',
        'total_rating': 92.0,
        'cover': {
          'url': '//images.igdb.com/igdb/image/upload/t_thumb/co1wyy.jpg'
        },
        'genres': [
          {'name': 'Role-playing (RPG)'},
          {'name': 'Adventure'},
        ],
        'platforms': [
          {'name': 'PC'},
          {'name': 'PlayStation 4'},
          {'name': 'Xbox One'},
          {'name': 'Nintendo Switch'},
        ],
        'involved_companies': [
          {
            'company': {'name': 'CD PROJEKT RED'},
            'publisher': true,
          }
        ]
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(normalized['genres'], goldenEnvelope.normalized['genres']);
      expect(normalized['platforms'], goldenEnvelope.normalized['platforms']);
      expect(normalized['audience_rating'],
          goldenEnvelope.normalized['audience_rating']);
      expect(normalized['cover_image_url'],
          goldenEnvelope.normalized['cover_image_url']);
      expect(jsonObject(normalized['provider_ids'])['igdb'],
          jsonObject(goldenEnvelope.normalized['provider_ids'])['igdb']);
    });
  });
}
