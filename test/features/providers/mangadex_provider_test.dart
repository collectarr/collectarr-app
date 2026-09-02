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
  group('MangaDexProvider', () {
    test('exposes correct descriptor metadata', () {
      final provider = MangaDexProvider();
      expect(provider.name, 'mangadex');
      expect(provider.descriptor.displayName, 'MangaDex');
      expect(provider.descriptor.kind, 'manga');
      expect(provider.descriptor.supportedKinds, ['manga']);
      expect(provider.descriptor.requiresUserKey, isFalse);
      expect(provider.isConfigured, isTrue);
      expect(provider.descriptor.rateLimit, '5 req/sec');
    });

    test('search queries manga endpoint and formats search candidates',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path, '/manga');
        expect(options.queryParameters['title'], 'Chainsaw Man');
        return ResponseBody.fromString(
          jsonEncode({
            'data': [
              {
                'id': 'd7037b2a-874a-4360-8a7b-07f2001542a9',
                'attributes': {
                  'title': {'en': 'Chainsaw Man'},
                  'status': 'ongoing',
                  'year': 2018,
                  'publicationDemographic': 'shounen',
                },
                'relationships': [
                  {
                    'type': 'cover_art',
                    'attributes': {'fileName': 'cover.jpg'},
                  }
                ]
              }
            ]
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'mangadex',
        baseUrl: 'https://api.mangadex.org',
        dio: dio,
      );
      final provider = MangaDexProvider(httpClient: client);

      final results = await provider.search('Chainsaw Man');
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'mangadex');
      expect(item.providerItemId, 'd7037b2a-874a-4360-8a7b-07f2001542a9');
      expect(item.title, 'Chainsaw Man');
      expect(item.kind, 'manga');
      expect(item.summary, 'shounen · ongoing · 2018');
      expect(
        item.imageUrl,
        'https://uploads.mangadex.org/covers/d7037b2a-874a-4360-8a7b-07f2001542a9/cover.jpg.256.jpg',
      );
    });

    test('fetchItem fetches manga details and outputs normalized envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'data': {
              'id': 'd7037b2a-874a-4360-8a7b-07f2001542a9',
              'attributes': {
                'title': {'en': 'Chainsaw Man'},
                'description': {
                  'en':
                      'Denji is a teenage boy living with a Chainsaw Devil named Pochita.'
                },
                'tags': [
                  {
                    'attributes': {
                      'name': {'en': 'Action'}
                    }
                  },
                  {
                    'attributes': {
                      'name': {'en': 'Supernatural'}
                    }
                  }
                ]
              },
              'relationships': [
                {
                  'type': 'author',
                  'attributes': {'name': 'Tatsuki Fujimoto'}
                },
                {
                  'type': 'cover_art',
                  'attributes': {'fileName': 'cover.jpg'}
                }
              ]
            }
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'mangadex',
        baseUrl: 'https://api.mangadex.org',
        dio: dio,
      );
      final provider = MangaDexProvider(httpClient: client);

      final envelope =
          await provider.fetchItem('d7037b2a-874a-4360-8a7b-07f2001542a9');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'mangadex');
      expect(envelope.providerItemId, 'd7037b2a-874a-4360-8a7b-07f2001542a9');
      expect(envelope.kind, 'manga');
      expect(envelope.normalized['title'], 'Chainsaw Man');
      expect(
          envelope.normalized['synopsis'], contains('Denji is a teenage boy'));
      expect(envelope.normalized['genres'],
          containsAll(['Action', 'Supernatural']));
      expect(envelope.normalized['creators'], hasLength(1));
        expect(jsonObjectList(envelope.normalized['creators']).first['name'],
          'Tatsuki Fujimoto');
        expect(jsonObjectList(envelope.normalized['creators']).first['role'],
          'Author');
      expect(envelope.images, hasLength(1));
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for MangaDex', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final mdFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'mangadex',
        orElse: () => null,
      );
      expect(mdFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(mdFixtureRaw as Map),
      );

      final provider = MangaDexProvider();
      final normalized = provider.normalize({
        'id': 'd7037b2a-874a-4360-8a7b-07f2001542a9',
        'attributes': {
          'title': {'en': 'Chainsaw Man'},
          'publisher': 'Shueisha',
          'description': {
            'en':
                'Denji is a teenage boy living with a Chainsaw Devil named Pochita.'
          },
          'tags': [
            {
              'attributes': {
                'name': {'en': 'Action'}
              }
            },
            {
              'attributes': {
                'name': {'en': 'Supernatural'}
              }
            },
            {
              'attributes': {
                'name': {'en': 'Comedy'}
              }
            }
          ]
        },
        'relationships': [
          {
            'type': 'author',
            'attributes': {'name': 'Tatsuki Fujimoto'}
          }
        ]
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(normalized['genres'], goldenEnvelope.normalized['genres']);
      expect(jsonObject(normalized['provider_ids'])['mangadex'],
          jsonObject(goldenEnvelope.normalized['provider_ids'])['mangadex']);
        expect(jsonObjectList(normalized['creators']).first['name'],
          jsonObjectList(goldenEnvelope.normalized['creators']).first['name']);
    });
  });
}
