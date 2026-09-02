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
  group('HardcoverProvider', () {
    test('exposes correct descriptor metadata', () {
      final provider = HardcoverProvider();
      expect(provider.name, 'hardcover');
      expect(provider.descriptor.displayName, 'Hardcover');
      expect(provider.descriptor.kind, 'book');
      expect(
          provider.descriptor.supportedKinds, containsAll(['book', 'manga']));
      expect(provider.descriptor.requiresUserKey, isTrue);
      expect(provider.isConfigured, isFalse);
      expect(provider.descriptor.rateLimit, '60 req/min');
    });

    test('throws ProviderAuthException when unconfigured', () async {
      final provider = HardcoverProvider();
      expect(
          () => provider.search('Dune'), throwsA(isA<ProviderAuthException>()));
    });

    test('search queries GraphQL search endpoint and formats candidates',
        () async {
      String? sentAuthHeader;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        sentAuthHeader = options.headers['Authorization']?.toString();
        return ResponseBody.fromString(
          jsonEncode({
            'data': {
              'search': {
                'results': [
                  {
                    'document': {
                      'id': 1234,
                      'title': 'Dune',
                      'author_names': ['Frank Herbert'],
                      'release_year': 1965,
                      'image': {
                        'url': 'https://assets.hardcover.app/covers/dune.jpg'
                      },
                    }
                  }
                ]
              }
            }
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      const creds = HardcoverCredentials(apiKey: 'hardcover-secret-token');
      final client = ProviderHttpClient(
        provider: 'hardcover',
        baseUrl: 'https://api.hardcover.app/v1/graphql',
        dio: dio,
      );
      final provider =
          HardcoverProvider(credentials: creds, httpClient: client);
      expect(provider.isConfigured, isTrue);

      final results = await provider.search('Dune');
      expect(sentAuthHeader, 'Bearer hardcover-secret-token');
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'hardcover');
      expect(item.providerItemId, '1234');
      expect(item.title, 'Dune');
      expect(item.kind, 'book');
      expect(item.summary, 'Frank Herbert · 1965');
      expect(item.imageUrl, 'https://assets.hardcover.app/covers/dune.jpg');
    });

    test('fetchItem fetches book details and outputs standardized envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'data': {
              'books': [
                {
                  'id': 1234,
                  'title': 'Dune',
                  'description':
                      'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides.',
                  'pages': 688,
                  'slug': 'dune',
                  'image': {
                    'url': 'https://assets.hardcover.app/covers/dune.jpg'
                  },
                  'contributions': [
                    {
                      'author': {'name': 'Frank Herbert'},
                      'contribution_type': 'Author',
                    }
                  ],
                  'editions': [
                    {
                      'publisher': {'name': 'Chilton Books'},
                      'pages': 688,
                    }
                  ],
                  'taggings': [
                    {
                      'tag': {'tag': 'Science Fiction'}
                    },
                    {
                      'tag': {'tag': 'Space Opera'}
                    }
                  ]
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

      const creds = HardcoverCredentials(apiKey: 'hardcover-secret-token');
      final client = ProviderHttpClient(
        provider: 'hardcover',
        baseUrl: 'https://api.hardcover.app/v1/graphql',
        dio: dio,
      );
      final provider =
          HardcoverProvider(credentials: creds, httpClient: client);

      final envelope = await provider.fetchItem('1234');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'hardcover');
      expect(envelope.providerItemId, '1234');
      expect(envelope.kind, 'book');
      expect(envelope.normalized['title'], 'Dune');
      expect(envelope.normalized['synopsis'],
          contains('Set on the desert planet'));
      expect(envelope.normalized['publisher'], 'Chilton Books');
      expect(envelope.normalized['page_count'], 688);
      expect(envelope.normalized['genres'],
          containsAll(['Science Fiction', 'Space Opera']));
      expect(envelope.normalized['creators'], hasLength(1));
        expect(jsonObjectList(envelope.normalized['creators']).first['name'],
          'Frank Herbert');
        expect(jsonObjectList(envelope.normalized['creators']).first['role'],
          'Author');
      expect(envelope.images, hasLength(1));
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for Hardcover', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final hcFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'hardcover',
        orElse: () => null,
      );
      expect(hcFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(hcFixtureRaw as Map),
      );

      final provider = HardcoverProvider();
      final normalized = provider.normalize({
        'id': 1234,
        'title': 'Dune',
        'description':
            'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides.',
        'pages': 688,
        '_collectarr_kind': 'book',
        'image': {'url': 'https://assets.hardcover.app/covers/dune.jpg'},
        'contributions': [
          {
            'author': {'name': 'Frank Herbert'},
            'contribution_type': 'Author',
          }
        ],
        'editions': [
          {
            'publisher': {'name': 'Chilton Books'},
            'pages': 688,
          }
        ],
        'taggings': [
          {
            'tag': {'tag': 'Science Fiction'}
          },
          {
            'tag': {'tag': 'Space Opera'}
          }
        ]
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['page_count'], goldenEnvelope.normalized['page_count']);
      expect(normalized['genres'], goldenEnvelope.normalized['genres']);
        expect(jsonObject(normalized['provider_ids'])['hardcover'],
          jsonObject(goldenEnvelope.normalized['provider_ids'])['hardcover']);
        expect(jsonObjectList(normalized['creators']).first['name'],
          jsonObjectList(goldenEnvelope.normalized['creators']).first['name']);
        expect(jsonObjectList(normalized['creators']).first['role'],
          jsonObjectList(goldenEnvelope.normalized['creators']).first['role']);
    });
  });
}
