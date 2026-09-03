import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
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

const String _gloomhavenXmlFixture = '''
<items>
  <item type="boardgame" id="174430">
    <thumbnail>https://cf.geekdo-images.com/gloomhaven_thumb.jpg</thumbnail>
    <image>https://cf.geekdo-images.com/gloomhaven.jpg</image>
    <name type="primary" sortindex="1" value="Gloomhaven"/>
    <description>Gloomhaven is a game of Euro-inspired tactical combat in a persistent world of shifting motives.</description>
    <yearpublished value="2017"/>
    <minplayers value="1"/>
    <maxplayers value="4"/>
    <playingtime value="120"/>
    <minplaytime value="60"/>
    <maxplaytime value="120"/>
    <minage value="14"/>
    <link type="boardgamecategory" id="1022" value="Adventure"/>
    <link type="boardgamecategory" id="1010" value="Fantasy"/>
    <link type="boardgamecategory" id="1047" value="Miniatures"/>
    <link type="boardgamedesigner" id="69802" value="Isaac Childres"/>
    <link type="boardgamepublisher" id="27425" value="Cephalofair Games"/>
  </item>
</items>
''';

void main() {
  group('BGGProvider', () {
    test('decodes native XML board game model', () {
      final thing = BggThing.fromXml(
        XmlDocument.parse(_gloomhavenXmlFixture).findAllElements('item').single,
      );

      expect(thing.id, '174430');
      expect(thing.names.single.value, 'Gloomhaven');
      expect(thing.description, contains('tactical combat'));
      expect(thing.yearPublished, 2017);
      expect(thing.minPlayers, 1);
      expect(thing.playingTime, 120);
      expect(thing.links.first.value, 'Adventure');
      expect(thing.toJson()['maxplayers'], 4);
    });

    test('exposes correct descriptor metadata', () {
      final provider = BGGProvider();
      expect(provider.name, 'bgg');
      expect(provider.descriptor.displayName, 'BoardGameGeek');
      expect(provider.descriptor.kind, 'boardgame');
      expect(provider.descriptor.supportedKinds, contains('boardgame'));
      expect(provider.descriptor.requiresUserKey, isTrue);
      expect(provider.isConfigured, isFalse);
      expect(provider.descriptor.rateLimit, '2 req/sec');
    });

    test('throws ProviderAuthException when unconfigured', () async {
      final provider = BGGProvider();
      expect(() => provider.search('Gloomhaven'),
          throwsA(isA<ProviderAuthException>()));
    });

    test('search queries search endpoint with XML and formats candidates',
        () async {
      String? sentAuthHeader;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        sentAuthHeader = options.headers['Authorization']?.toString();
        return ResponseBody.fromString(
          '''
<items total="1" termsofuse="https://boardgamegeek.com/xmlapi/termsofuse">
  <item type="boardgame" id="174430">
    <name type="primary" value="Gloomhaven"/>
    <yearpublished value="2017"/>
  </item>
</items>
''',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/xml'],
          },
        );
      });

      const creds = BggCredentials(apiToken: 'bgg-test-token');
      final client = ProviderHttpClient(
        provider: 'bgg',
        baseUrl: 'https://boardgamegeek.com/xmlapi2',
        dio: dio,
      );
      final provider = BGGProvider(credentials: creds, httpClient: client);
      expect(provider.isConfigured, isTrue);

      final results = await provider.search('Gloomhaven');
      expect(sentAuthHeader, 'Bearer bgg-test-token');
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'bgg');
      expect(item.providerItemId, '174430');
      expect(item.title, 'Gloomhaven');
      expect(item.kind, 'boardgame');
      expect(item.summary, '2017');
    });

    test('fetchItem fetches thing details and outputs standardized envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path, '/thing');
        expect(options.queryParameters['id'], '174430');
        return ResponseBody.fromString(
          _gloomhavenXmlFixture,
          200,
          headers: {
            Headers.contentTypeHeader: ['application/xml'],
          },
        );
      });

      const creds = BggCredentials(apiToken: 'bgg-test-token');
      final client = ProviderHttpClient(
        provider: 'bgg',
        baseUrl: 'https://boardgamegeek.com/xmlapi2',
        dio: dio,
      );
      final provider = BGGProvider(credentials: creds, httpClient: client);

      final envelope = await provider.fetchItem('174430');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'bgg');
      expect(envelope.providerItemId, '174430');
      expect(envelope.kind, 'boardgame');
      expect(envelope.normalized['title'], 'Gloomhaven');
      expect(envelope.normalized['publisher'], 'Cephalofair Games');
      expect(envelope.normalized['min_players'], 1);
      expect(envelope.normalized['max_players'], 4);
      expect(envelope.normalized['min_age'], 14);
      expect(envelope.normalized['playing_time_minutes'], 120);
      expect(envelope.normalized['genres'],
          containsAll(['Adventure', 'Fantasy', 'Miniatures']));
      expect(envelope.normalized['creators'], hasLength(1));
      expect(jsonObjectList(envelope.normalized['creators'])[0]['name'],
          'Isaac Childres');
      expect(jsonObjectList(envelope.normalized['creators'])[0]['role'],
          'Designer');
      expect(envelope.images, hasLength(1));
      expect(envelope.images[0].url,
          'https://cf.geekdo-images.com/gloomhaven.jpg');
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for BGG', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final bggFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'bgg',
        orElse: () => null,
      );
      expect(bggFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(bggFixtureRaw as Map),
      );

      final provider = BGGProvider();
      final normalized = provider.normalize({
        'id': '174430',
        'type': 'boardgame',
        'names': [
          {'type': 'primary', 'sortindex': '1', 'value': 'Gloomhaven'},
        ],
        'description':
            'Gloomhaven is a game of Euro-inspired tactical combat in a persistent world of shifting motives.',
        'yearpublished': '2017',
        'minplayers': '1',
        'maxplayers': '4',
        'playingtime': '120',
        'minage': '14',
        'image': 'https://cf.geekdo-images.com/gloomhaven.jpg',
        'thumbnail': 'https://cf.geekdo-images.com/gloomhaven_thumb.jpg',
        'links': [
          {'type': 'boardgamecategory', 'id': '1022', 'value': 'Adventure'},
          {'type': 'boardgamecategory', 'id': '1010', 'value': 'Fantasy'},
          {'type': 'boardgamecategory', 'id': '1047', 'value': 'Miniatures'},
          {
            'type': 'boardgamedesigner',
            'id': '69802',
            'value': 'Isaac Childres'
          },
          {
            'type': 'boardgamepublisher',
            'id': '27425',
            'value': 'Cephalofair Games'
          },
        ],
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(
          normalized['min_players'], goldenEnvelope.normalized['min_players']);
      expect(
          normalized['max_players'], goldenEnvelope.normalized['max_players']);
      expect(normalized['min_age'], goldenEnvelope.normalized['min_age']);
      expect(normalized['playing_time_minutes'],
          goldenEnvelope.normalized['playing_time_minutes']);
      expect(normalized['genres'], goldenEnvelope.normalized['genres']);
      expect(jsonObject(normalized['provider_ids'])['bgg'],
          jsonObject(goldenEnvelope.normalized['provider_ids'])['bgg']);
      expect(jsonObjectList(normalized['creators'])[0]['name'],
          jsonObjectList(goldenEnvelope.normalized['creators'])[0]['name']);
      expect(jsonObjectList(normalized['creators'])[0]['role'],
          jsonObjectList(goldenEnvelope.normalized['creators'])[0]['role']);
    });
  });
}
