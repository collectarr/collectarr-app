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
  group('ComicVineProvider', () {
    test('decodes issue aggregates into provider-native models', () {
      final issue = ComicVineIssue.fromJson({
        'id': 160294,
        'issue_number': '1',
        'volume': {
          'name': 'Absolute Batman',
          'start_year': '2024',
          'publisher': {'name': 'DC Comics'},
        },
        'image': {'scale_large': 'https://example.com/cover.jpg'},
        'person_credits': [
          {'name': 'Scott Snyder', 'role': 'Writer'},
        ],
      });

      expect(issue.id, '160294');
      expect(issue.issueNumber, '1');
      expect(issue.volume?.name, 'Absolute Batman');
      expect(issue.volume?.startYear, 2024);
      expect(issue.volume?.publisherName, 'DC Comics');
      expect(issue.image?.scaleLarge, 'https://example.com/cover.jpg');
      expect(issue.personCredits.single.name, 'Scott Snyder');
      final volume = issue.toJson()['volume'];
      expect(volume, isA<Map<String, dynamic>>());
      if (volume is Map<String, dynamic>) {
        expect(volume['name'], 'Absolute Batman');
      }
    });

    test('exposes correct descriptor metadata', () {
      final provider = ComicVineProvider();
      expect(provider.name, 'comicvine');
      expect(provider.descriptor.displayName, 'Comic Vine');
      expect(provider.descriptor.kind, 'comic');
      expect(
          provider.descriptor.supportedKinds, containsAll(['comic', 'manga']));
      expect(provider.descriptor.requiresUserKey, isTrue);
      expect(provider.isConfigured, isFalse);
      expect(provider.descriptor.rateLimit, '200 req/15min');
    });

    test('throws ProviderAuthException when unconfigured', () async {
      final provider = ComicVineProvider();
      expect(() => provider.search('Absolute Batman'),
          throwsA(isA<ProviderAuthException>()));
    });

    test('search queries Comic Vine search endpoint and formats candidates',
        () async {
      String? sentApiKey;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        sentApiKey = options.queryParameters['api_key']?.toString();
        return ResponseBody.fromString(
          jsonEncode({
            'results': [
              {
                'id': 160294,
                'name': 'The Zoo',
                'issue_number': '1',
                'volume': {'name': 'Absolute Batman'},
                'image': {
                  'scale_large':
                      'https://comicvine.gamespot.com/a/uploads/scale_large/1/1/batman1.jpg'
                },
              }
            ]
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      const creds = ComicVineCredentials(apiKey: 'cv-api-key-test');
      final client = ProviderHttpClient(
        provider: 'comicvine',
        baseUrl: 'https://comicvine.gamespot.com/api',
        dio: dio,
      );
      final provider =
          ComicVineProvider(credentials: creds, httpClient: client);
      expect(provider.isConfigured, isTrue);

      final results = await provider.search('Absolute Batman');
      expect(sentApiKey, 'cv-api-key-test');
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'comicvine');
      expect(item.providerItemId, '4000-160294');
      expect(item.title, 'Absolute Batman #1');
      expect(item.kind, 'comic');
      expect(item.summary, 'Absolute Batman #1');
      expect(item.imageUrl,
          'https://comicvine.gamespot.com/a/uploads/scale_large/1/1/batman1.jpg');
    });

    test('fetchItem fetches issue details and outputs standardized envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path, '/issue/4000-160294/');
        return ResponseBody.fromString(
          jsonEncode({
            'results': {
              'id': 160294,
              'name': 'The Zoo',
              'issue_number': '1',
              'description':
                  '<p>In this new DC Absolute universe, Bruce Wayne has no money, no mansion, and no butler.</p>',
              'site_detail_url':
                  'https://comicvine.gamespot.com/absolute-batman-1/4000-160294/',
              'volume': {
                'name': 'Absolute Batman',
                'start_year': '2024',
                'publisher': {'name': 'DC Comics'}
              },
              'image': {
                'scale_large':
                    'https://comicvine.gamespot.com/a/uploads/scale_large/1/1/batman1.jpg',
              },
              'person_credits': [
                {'name': 'Scott Snyder', 'role': 'Writer'},
                {'name': 'Nick Dragotta', 'role': 'Artist'},
              ],
              'associated_images': [
                {
                  'caption': 'Variant Cover B',
                  'scale_large':
                      'https://comicvine.gamespot.com/a/uploads/scale_large/1/1/batman1b.jpg',
                  'square_mini':
                      'https://comicvine.gamespot.com/a/uploads/square_mini/1/1/batman1b.jpg',
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

      const creds = ComicVineCredentials(apiKey: 'cv-api-key-test');
      final client = ProviderHttpClient(
        provider: 'comicvine',
        baseUrl: 'https://comicvine.gamespot.com/api',
        dio: dio,
      );
      final provider =
          ComicVineProvider(credentials: creds, httpClient: client);

      final envelope = await provider.fetchItem('4000-160294');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'comicvine');
      expect(envelope.providerItemId, '4000-160294');
      expect(envelope.kind, 'comic');
      expect(envelope.normalized['title'], 'Absolute Batman #1');
      expect(envelope.normalized['series_title'], 'Absolute Batman');
      expect(envelope.normalized['item_number'], '1');
      expect(envelope.normalized['volume_start_year'], 2024);
      expect(envelope.normalized['publisher'], 'DC Comics');
      expect(envelope.normalized['synopsis'],
          contains('In this new DC Absolute universe'));
      expect(envelope.normalized['creators'], hasLength(2));
      expect(jsonObjectList(envelope.normalized['creators'])[0]['name'],
          'Scott Snyder');
      expect(
          jsonObjectList(envelope.normalized['creators'])[0]['role'], 'Writer');
      expect(envelope.normalized['variant_covers'], hasLength(1));
      expect(envelope.images, hasLength(2));
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for Comic Vine', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final cvFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'comicvine',
        orElse: () => null,
      );
      expect(cvFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(cvFixtureRaw as Map),
      );

      final provider = ComicVineProvider();
      final normalized = provider.normalize({
        'id': 160294,
        'name': 'The Zoo',
        'issue_number': '1',
        'description':
            '<p>In this new DC Absolute universe, Bruce Wayne has no money, no mansion, and no butler.</p>',
        'media_type': 'comic',
        'volume': {
          'name': 'Absolute Batman',
          'start_year': '2024',
          'publisher': {'name': 'DC Comics'}
        },
        'image': {
          'scale_large':
              'https://comicvine.gamespot.com/a/uploads/scale_large/1/1/batman1.jpg',
        },
        'person_credits': [
          {'name': 'Scott Snyder', 'role': 'Writer'},
          {'name': 'Nick Dragotta', 'role': 'Artist'},
        ],
        'associated_images': [
          {
            'caption': 'Variant Cover B',
            'scale_large':
                'https://comicvine.gamespot.com/a/uploads/scale_large/1/1/batman1b.jpg',
            'square_mini':
                'https://comicvine.gamespot.com/a/uploads/square_mini/1/1/batman1b.jpg',
          }
        ]
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['series_title'],
          goldenEnvelope.normalized['series_title']);
      expect(
          normalized['item_number'], goldenEnvelope.normalized['item_number']);
      expect(normalized['volume_start_year'],
          goldenEnvelope.normalized['volume_start_year']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(jsonObject(normalized['provider_ids'])['comicvine'],
          jsonObject(goldenEnvelope.normalized['provider_ids'])['comicvine']);
      expect(jsonObjectList(normalized['creators'])[0]['name'],
          jsonObjectList(goldenEnvelope.normalized['creators'])[0]['name']);
      expect(jsonObjectList(normalized['creators'])[0]['role'],
          jsonObjectList(goldenEnvelope.normalized['creators'])[0]['role']);
      expect(
          jsonObjectList(normalized['variant_covers'])[0]['name'],
          jsonObjectList(goldenEnvelope.normalized['variant_covers'])[0]
              ['name']);
      expect(
          jsonObjectList(normalized['variant_covers'])[0]['cover_image_url'],
          jsonObjectList(goldenEnvelope.normalized['variant_covers'])[0]
              ['cover_image_url']);
    });
  });
}
