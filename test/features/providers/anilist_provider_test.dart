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
  group('AniListProvider', () {
    test('exposes correct descriptor metadata for manga and anime', () {
      final provider = AniListProvider();
      expect(provider.name, 'anilist');
      expect(provider.descriptor.displayName, 'AniList');
      expect(provider.descriptor.kind, 'manga');
      expect(
          provider.descriptor.supportedKinds, containsAll(['manga', 'anime']));
      expect(provider.descriptor.requiresUserKey, isFalse);
      expect(provider.isConfigured, isTrue);
      expect(provider.descriptor.rateLimit, '90 req/min');
    });

    test('search queries GraphQL and formats search candidates', () async {
      String? sentQuery;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        final body = options.data is Map
            ? options.data as Map
            : jsonDecode(options.data.toString()) as Map;
        sentQuery = body['query']?.toString();

        return ResponseBody.fromString(
          jsonEncode({
            'data': {
              'Page': {
                'media': [
                  {
                    'id': 30002,
                    'type': 'MANGA',
                    'title': {
                      'english': 'Berserk',
                      'romaji': 'Berserk',
                    },
                    'format': 'MANGA',
                    'status': 'RELEASING',
                    'startDate': {'year': 1989},
                    'coverImage': {
                      'large':
                          'https://s4.anilist.co/file/anilistcdn/media/manga/cover/large/bx30002-777.jpg',
                    },
                    'characters': {
                      'edges': [
                        {
                          'node': {
                            'name': {'full': 'Guts'}
                          }
                        },
                        {
                          'node': {
                            'name': {'full': 'Griffith'}
                          }
                        }
                      ]
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

      final client = ProviderHttpClient(
        provider: 'anilist',
        dio: dio,
      );
      final provider = AniListProvider(httpClient: client);

      final results = await provider.search('Berserk', kind: 'manga');
      expect(sentQuery, contains('MANGA'));
      expect(results, hasLength(1));

      final item = results.first;
      expect(item.provider, 'anilist');
      expect(item.providerItemId, '30002');
      expect(item.title, 'Berserk');
      expect(item.kind, 'manga');
      expect(item.summary, contains('MANGA'));
      expect(item.summary, contains('1989'));
      expect(item.characterPreview, containsAll(['Guts', 'Griffith']));
    });

    test('fetchItem fetches media details and outputs standardized envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'data': {
              'Media': {
                'id': 30002,
                'idMal': 2,
                'type': 'MANGA',
                'title': {
                  'english': 'Berserk',
                  'romaji': 'Berserk',
                },
                'description':
                    'Guts, a former mercenary known as the Black Swordsman, seeks revenge.',
                'coverImage': {
                  'large':
                      'https://s4.anilist.co/file/anilistcdn/media/manga/cover/large/bx30002-777.jpg',
                },
                'genres': ['Action', 'Adventure', 'Dark Fantasy'],
                'staff': {
                  'edges': [
                    {
                      'role': 'Story & Art',
                      'node': {
                        'name': {'full': 'Kentarou Miura'}
                      }
                    }
                  ]
                }
              }
            }
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'anilist',
        dio: dio,
      );
      final provider = AniListProvider(httpClient: client);

      final envelope = await provider.fetchItem('30002', kind: 'manga');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'anilist');
      expect(envelope.providerItemId, '30002');
      expect(envelope.kind, 'manga');
      expect(envelope.normalized['title'], 'Berserk');
      expect(envelope.normalized['synopsis'],
          contains('Guts, a former mercenary'));
      expect(envelope.normalized['genres'],
          containsAll(['Action', 'Adventure', 'Dark Fantasy']));
      expect(envelope.normalized['creators'], hasLength(1));
      expect(envelope.normalized['creators'].first['name'], 'Kentarou Miura');
      expect(envelope.normalized['creators'].first['role'], 'Story & Art');
      expect(envelope.normalized['provider_ids']['anilist'], '30002');
      expect(envelope.normalized['provider_ids']['mal'], '2');
      expect(envelope.images, hasLength(1));
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for AniList', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final aniFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'anilist',
        orElse: () => null,
      );
      expect(aniFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(aniFixtureRaw as Map),
      );

      final provider = AniListProvider();
      final normalized = provider.normalize({
        'id': 30002,
        'idMal': 2,
        'type': 'MANGA',
        'title': {'english': 'Berserk'},
        'description':
            'Guts, a former mercenary known as the Black Swordsman, seeks revenge.',
        'coverImage': {
          'large':
              'https://s4.anilist.co/file/anilistcdn/media/manga/cover/large/bx30002-777.jpg',
        },
        'genres': ['Action', 'Adventure', 'Dark Fantasy'],
        'staff': {
          'edges': [
            {
              'role': 'Story & Art',
              'node': {
                'name': {'full': 'Kentarou Miura'}
              }
            }
          ]
        },
      });

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(normalized['genres'], goldenEnvelope.normalized['genres']);
      expect(normalized['cover_image_url'],
          goldenEnvelope.normalized['cover_image_url']);
      expect(normalized['provider_ids']['anilist'],
          goldenEnvelope.normalized['provider_ids']['anilist']);
      expect(normalized['provider_ids']['mal'],
          goldenEnvelope.normalized['provider_ids']['mal']);
      expect(normalized['creators'].first['name'],
          goldenEnvelope.normalized['creators'].first['name']);
      expect(normalized['creators'].first['role'],
          goldenEnvelope.normalized['creators'].first['role']);
    });
  });
}
