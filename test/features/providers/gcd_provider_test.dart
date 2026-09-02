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
  group('GCDProvider', () {
    test('exposes correct descriptor metadata', () {
      final provider = GCDProvider();
      expect(provider.name, 'gcd');
      expect(provider.descriptor.displayName, 'Grand Comics Database');
      expect(provider.descriptor.kind, 'comic');
      expect(provider.descriptor.supportedKinds, ['comic']);
      expect(provider.descriptor.requiresUserKey, isFalse);
      expect(provider.isConfigured, isTrue);
      expect(provider.descriptor.rateLimit, '2 req/sec');
    });

    test('search parses series name and issue number and queries endpoint',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path,
            contains('/series/name/Amazing%20Spider-Man/issue/300/'));
        return ResponseBody.fromString(
          jsonEncode({
            'results': [
              {
                'id': 12345,
                'api_url': '/issue/12345/',
                'series_name': 'The Amazing Spider-Man (1963 series)',
                'descriptor': '300',
                'publication_date': 'May 1988',
                'price': '1.50 USD',
                'cover': 'https://www.comics.org/media/img/covers/12345.jpg',
                'story_set': [
                  {
                    'characters': 'Spider-Man; Venom (first appearance)',
                    'part_of_issue_story_arc': 'Venom',
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
        provider: 'gcd',
        baseUrl: 'https://www.comics.org/api',
        dio: dio,
      );
      final provider = GCDProvider(httpClient: client);

      final results = await provider.search('Amazing Spider-Man #300');
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'gcd');
      expect(item.providerItemId, '12345');
      expect(item.title, 'The Amazing Spider-Man (1963 series) #300');
      expect(item.kind, 'comic');
      expect(item.summary, 'May 1988 · 1.50 USD');
      expect(
          item.imageUrl, 'https://www.comics.org/media/img/covers/12345.jpg');
      expect(item.characterPreview, containsAll(['Spider-Man', 'Venom']));
      expect(item.storyArcPreview, contains('Venom'));
    });

    test('fetchItem fetches issue details and outputs standardized envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path, '/issue/12345/');
        return ResponseBody.fromString(
          jsonEncode({
            'id': 12345,
            'api_url': '/issue/12345/',
            'series_name': 'The Amazing Spider-Man (1963 series)',
            'number': '300',
            'publisher_name': 'Marvel Comics',
            'cover': 'https://www.comics.org/media/img/covers/12345.jpg',
            'story_set': [
              {
                'title': 'Venom',
                'script': 'David Michelinie',
                'pencils': 'Todd McFarlane',
                'synopsis': 'Venom makes his first full appearance.',
                'characters': 'Spider-Man; Venom',
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
        provider: 'gcd',
        baseUrl: 'https://www.comics.org/api',
        dio: dio,
      );
      final provider = GCDProvider(httpClient: client);

      final envelope = await provider.fetchItem('12345');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'gcd');
      expect(envelope.providerItemId, '12345');
      expect(envelope.kind, 'comic');
      expect(envelope.normalized['title'], 'The Amazing Spider-Man #300');
      expect(envelope.normalized['series_title'], 'The Amazing Spider-Man');
      expect(envelope.normalized['item_number'], '300');
      expect(envelope.normalized['publisher'], 'Marvel Comics');
      expect(envelope.normalized['synopsis'],
          contains('Venom makes his first full appearance.'));
      expect(envelope.normalized['creators'], hasLength(2));
        expect(jsonObjectList(envelope.normalized['creators'])[0]['name'],
          'David Michelinie');
        expect(jsonObjectList(envelope.normalized['creators'])[0]['role'],
          'writer');
        expect(jsonObjectList(envelope.normalized['creators'])[1]['name'],
          'Todd McFarlane');
        expect(jsonObjectList(envelope.normalized['creators'])[1]['role'],
          'penciller');
      expect(envelope.normalized['characters'], hasLength(2));
      expect(envelope.images, hasLength(1));
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for GCD', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final gcdFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'gcd',
        orElse: () => null,
      );
      expect(gcdFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(gcdFixtureRaw as Map),
      );

      final provider = GCDProvider();
      final normalized = provider.normalize({
        'id': '12345',
        'title': 'Amazing Spider-Man #300',
        'series_name': 'The Amazing Spider-Man',
        'number': '300',
        'publisher_name': 'Marvel Comics',
        'cover': 'https://www.comics.org/media/img/covers/12345.jpg',
        'synopsis': 'Venom makes his first full appearance.',
        'story_set': [
          {
            'script': 'David Michelinie',
            'pencils': 'Todd McFarlane',
            'characters': 'Spider-Man; Venom',
          }
        ]
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['series_title'],
          goldenEnvelope.normalized['series_title']);
      expect(
          normalized['item_number'], goldenEnvelope.normalized['item_number']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(normalized['cover_image_url'],
          goldenEnvelope.normalized['cover_image_url']);
        expect(jsonObject(normalized['provider_ids'])['gcd'],
          jsonObject(goldenEnvelope.normalized['provider_ids'])['gcd']);
        expect(jsonObjectList(normalized['creators'])[0]['name'],
          jsonObjectList(goldenEnvelope.normalized['creators'])[0]['name']);
        expect(jsonObjectList(normalized['creators'])[0]['role'],
          jsonObjectList(goldenEnvelope.normalized['creators'])[0]['role']);
        expect(jsonObjectList(normalized['creators'])[1]['name'],
          jsonObjectList(goldenEnvelope.normalized['creators'])[1]['name']);
        expect(jsonObjectList(normalized['creators'])[1]['role'],
          jsonObjectList(goldenEnvelope.normalized['creators'])[1]['role']);
        expect(jsonObjectList(normalized['characters'])[0]['name'],
          jsonObjectList(goldenEnvelope.normalized['characters'])[0]['name']);
        expect(jsonObjectList(normalized['characters'])[1]['name'],
          jsonObjectList(goldenEnvelope.normalized['characters'])[1]['name']);
    });
  });
}
