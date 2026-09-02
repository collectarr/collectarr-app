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
  group('MusicBrainzProvider', () {
    test('exposes correct descriptor metadata', () {
      final provider = MusicBrainzProvider();
      expect(provider.name, 'musicbrainz');
      expect(provider.descriptor.displayName, 'MusicBrainz');
      expect(provider.descriptor.kind, 'music');
      expect(provider.descriptor.supportedKinds, ['music']);
      expect(provider.descriptor.requiresUserKey, isFalse);
      expect(provider.isConfigured, isTrue);
      expect(provider.descriptor.rateLimit, '1 req/sec');
    });

    test('search queries release endpoint and formats search candidates',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path, '/release');
        expect(options.queryParameters['query'], 'The Dark Side of the Moon');
        return ResponseBody.fromString(
          jsonEncode({
            'releases': [
              {
                'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
                'title': 'The Dark Side of the Moon',
                'date': '1973-03-01',
                'country': 'GB',
                'artist-credit': [
                  {
                    'artist': {'name': 'Pink Floyd'}
                  }
                ],
                'cover-art-archive': {'artwork': true, 'front': true},
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
        provider: 'musicbrainz',
        baseUrl: 'https://musicbrainz.org/ws/2',
        dio: dio,
      );
      final provider = MusicBrainzProvider(httpClient: client);

      final results = await provider.search('The Dark Side of the Moon');
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'musicbrainz');
      expect(item.providerItemId, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(item.title, 'The Dark Side of the Moon');
      expect(item.kind, 'music');
      expect(item.summary, 'Pink Floyd · 1973-03-01 · GB');
      expect(
        item.imageUrl,
        'https://coverartarchive.org/release/a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d/front.jpg',
      );
    });

    test('searchByBarcode formats barcode query', () async {
      String? queriedParam;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        queriedParam = options.queryParameters['query']?.toString();
        return ResponseBody.fromString(
          jsonEncode({'releases': <dynamic>[]}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'musicbrainz',
        baseUrl: 'https://musicbrainz.org/ws/2',
        dio: dio,
      );
      final provider = MusicBrainzProvider(httpClient: client);

      await provider.searchByBarcode('077774600125');
      expect(queriedParam, 'barcode:077774600125');
    });

    test('fetchItem parses tracks and output normalized envelope', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
            'title': 'The Dark Side of the Moon',
            'date': '1973-03-01',
            'country': 'GB',
            'barcode': '077774600125',
            'artist-credit': [
              {
                'artist': {'name': 'Pink Floyd'}
              }
            ],
            'label-info': [
              {
                'label': {'name': 'Harvest'}
              }
            ],
            'media': [
              {
                'track-count': 3,
                'format': 'Vinyl',
                'tracks': [
                  {'position': 1, 'title': 'Speak to Me', 'length': 67000},
                  {
                    'position': 2,
                    'title': 'Breathe (In the Air)',
                    'length': 169000
                  },
                  {'position': 3, 'title': 'Time', 'length': 425000},
                ]
              }
            ],
            'cover-art-archive': {'artwork': true, 'front': true},
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'musicbrainz',
        baseUrl: 'https://musicbrainz.org/ws/2',
        dio: dio,
      );
      final provider = MusicBrainzProvider(httpClient: client);

      final envelope =
          await provider.fetchItem('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'musicbrainz');
      expect(envelope.providerItemId, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(envelope.kind, 'music');
      expect(envelope.normalized['title'], 'The Dark Side of the Moon');
      expect(envelope.normalized['publisher'], 'Harvest');
      expect(envelope.normalized['track_count'], 3);
      expect(envelope.normalized['tracks'], hasLength(3));
      expect(jsonObjectList(envelope.normalized['tracks'])[0]['title'],
          'Speak to Me');
      expect(
          jsonObjectList(envelope.normalized['tracks'])[0]['duration_seconds'],
          67);
      expect(envelope.normalized['creators'], hasLength(1));
      expect(jsonObjectList(envelope.normalized['creators']).first['name'],
          'Pink Floyd');
      expect(envelope.images, hasLength(1));
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for MusicBrainz', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final mbFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'musicbrainz',
        orElse: () => null,
      );
      expect(mbFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(mbFixtureRaw as Map),
      );

      final provider = MusicBrainzProvider();
      final normalized = provider.normalize({
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'title': 'The Dark Side of the Moon',
        'artist-credit': [
          {
            'artist': {'name': 'Pink Floyd'}
          }
        ],
        'label-info': [
          {
            'label': {'name': 'Harvest'}
          }
        ],
        'genres': ['Progressive Rock', 'Psychedelic Rock'],
        'media': [
          {
            'track-count': 3,
            'tracks': [
              {'position': 1, 'title': 'Speak to Me', 'length': 67000},
              {
                'position': 2,
                'title': 'Breathe (In the Air)',
                'length': 169000
              },
              {'position': 3, 'title': 'Time', 'length': 425000},
            ]
          }
        ],
        'cover-art-archive': {'artwork': true, 'front': true},
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['genres'], goldenEnvelope.normalized['genres']);
      expect(
          normalized['track_count'], goldenEnvelope.normalized['track_count']);
      expect(normalized['tracks'], goldenEnvelope.normalized['tracks']);
      expect(jsonObject(normalized['provider_ids'])['musicbrainz'],
          jsonObject(goldenEnvelope.normalized['provider_ids'])['musicbrainz']);
      expect(jsonObjectList(normalized['creators']).first['name'],
          jsonObjectList(goldenEnvelope.normalized['creators']).first['name']);
      expect(jsonObjectList(normalized['creators']).first['role'],
          jsonObjectList(goldenEnvelope.normalized['creators']).first['role']);
    });
  });
}
