import 'dart:convert';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/musicbrainz/musicbrainz_music_mapper.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/runtime/provider_http_client.dart';
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
  group('MusicBrainzProvider', () {
    test('decodes native MusicBrainz release models', () {
      final release = MusicBrainzRelease.fromJson({
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'title': 'The Dark Side of the Moon',
        'date': '1973-03-01',
        'artist-credit': [
          {
            'artist': {
              'id': '83d91898-7763-47d7-b03b-b92132375c47',
              'name': 'Pink Floyd',
            },
          },
        ],
        'release-group': {
          'id': 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
          'title': 'The Dark Side of the Moon',
        },
        'label-info': [
          {
            'catalog-number': 'SHVL 804',
            'label': {'name': 'Harvest'},
          },
        ],
        'media': [
          {
            'track-count': 1,
            'format': 'Vinyl',
            'tracks': [
              {'position': 1, 'title': 'Speak to Me', 'length': 67000},
            ],
          },
        ],
        'cover-art-archive': {'artwork': true, 'front': true},
        'genres': [
          {'name': 'Progressive Rock'},
        ],
      });

      expect(release.id, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(release.artistCredits.single.artist?.name, 'Pink Floyd');
      expect(release.releaseGroup?.id, 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(release.labelInfo.single.catalogNumber, 'SHVL 804');
      expect(release.labelInfo.single.label?.name, 'Harvest');
      expect(release.media.single.tracks.single.length, 67000);
      expect(release.coverArtArchive?.front, isTrue);
      expect(release.genres, ['Progressive Rock']);
      expect(release.toJson()['title'], 'The Dark Side of the Moon');
    });

    test('exposes the protocol descriptor without kind-domain coupling', () {
      final provider = MusicBrainzProvider();

      expect(provider.name, 'musicbrainz');
      expect(
          MusicBrainzProvider.musicBrainzDescriptor.displayName, 'MusicBrainz');
      expect(MusicBrainzProvider.musicBrainzDescriptor.kind,
          CatalogMediaKind.music);
      expect(MusicBrainzProvider.musicBrainzDescriptor.supportedKinds,
          [CatalogMediaKind.music]);
      expect(
          MusicBrainzProvider.musicBrainzDescriptor.requiresUserKey, isFalse);
      expect(MusicBrainzProvider.musicBrainzDescriptor.rateLimit, '1 req/sec');
    });

    test('typed release search preserves provider fields and track artists',
        () async {
      final provider = _provider((options) async {
        expect(options.path, '/release');
        expect(options.queryParameters['query'], 'The Dark Side of the Moon');
        return _response({
          'releases': [
            {
              'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
              'title': 'The Dark Side of the Moon',
              'date': '1973-03-01',
              'country': 'GB',
              'release-group': {
                'id': 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
                'title': 'The Dark Side of the Moon',
              },
              'artist-credit': [
                {
                  'artist': {'name': 'Pink Floyd'}
                }
              ],
              'media': [
                {
                  'format': 'Vinyl',
                  'tracks': [
                    {
                      'position': 1,
                      'title': 'Speak to Me',
                      'length': 67000,
                      'artist-credit': [
                        {
                          'artist': {'name': 'David Gilmour'}
                        }
                      ],
                    }
                  ],
                }
              ],
            }
          ],
        });
      });

      final response = await provider.searchReleases(
        'The Dark Side of the Moon',
      );

      final release = MusicBrainzMusicMapper.releaseCandidate(
        response.payload.single,
        coverArtArchiveBaseUrl: 'https://coverartarchive.org',
        provenance: response.provenance,
        attribution: response.attribution,
      );
      expect(release.providerItemId, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(release.title, 'The Dark Side of the Moon');
      expect(release.artist, 'Pink Floyd');
      expect(release.summary, 'Pink Floyd / 1973-03-01 / GB');
      expect(release.mediums.single.format, 'Vinyl');
      expect(release.mediums.single.tracks.single.artist, 'David Gilmour');
    });

    test('typed release-group search returns a Work candidate', () async {
      const groupId = 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';
      final provider = _provider((options) async {
        expect(options.path, '/release-group');
        expect(options.queryParameters['query'], 'The Dark Side of the Moon');
        return _response({
          'release-groups': [
            {
              'id': groupId,
              'title': 'The Dark Side of the Moon',
              'first-release-date': '1973-03-01',
              'primary-type': 'Album',
              'artist-credit': [
                {
                  'artist': {'name': 'Pink Floyd'}
                }
              ],
            }
          ],
        });
      });

      final response = await provider.searchReleaseGroups(
        'The Dark Side of the Moon',
      );

      final group = MusicBrainzMusicMapper.releaseGroupCandidate(
        response.payload.single,
        coverArtArchiveBaseUrl: 'https://coverartarchive.org',
        provenance: response.provenance,
        attribution: response.attribution,
      );
      expect(response.payload, hasLength(1));
      expect(group, isA<MusicReleaseGroupCandidate>());
      expect(group.providerItemId, 'release-group:$groupId');
      expect(group.artist, 'Pink Floyd');
      expect(group.primaryType, 'Album');
      expect(group.releases, isEmpty);
    });

    test('typed release-group fetch retains every concrete child summary',
        () async {
      const groupId = 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';
      final provider = _provider((options) async {
        expect(options.path, '/release-group/$groupId');
        expect(options.queryParameters['inc'], 'artist-credits+releases+tags');
        return _response({
          'id': groupId,
          'title': 'The Dark Side of the Moon',
          'first-release-date': '1973-03-01',
          'artist-credit': [
            {
              'artist': {'name': 'Pink Floyd'}
            }
          ],
          'releases': [
            {
              'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
              'title': 'The Dark Side of the Moon',
              'date': '1973-03-01',
              'country': 'GB',
              'status': 'Official',
              'packaging': 'Jewel Case',
              'media': [
                {'format': 'CD'},
              ],
            },
            {
              'id': 'c1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
              'title': 'The Dark Side of the Moon (Remastered)',
              'date': '2011-09-26',
              'country': 'EU',
              'media': [
                {'format': 'CD'},
              ],
            },
          ],
          'tags': [
            {'name': 'progressive rock'}
          ],
        });
      });

      final envelope = await provider.fetchReleaseGroup(
        MusicBrainzProvider.releaseGroupProviderItemId(groupId),
      );
      final group = MusicBrainzMusicMapper.releaseGroupCandidate(
        envelope.payload,
        coverArtArchiveBaseUrl: 'https://coverartarchive.org',
        provenance: envelope.provenance,
        attribution: envelope.attribution,
      );

      expect(envelope.providerItemId, 'release-group:$groupId');
      expect(group.artist, 'Pink Floyd');
      expect(group.releases, hasLength(2));
      expect(group.releases.first.format, 'CD');
      expect(group.releases.last.providerItemId,
          'c1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
    });

    test('typed release fetch parses media and recording identity', () async {
      final releaseId = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';
      final provider = _provider((options) async {
        expect(options.path, '/release/$releaseId');
        expect(options.queryParameters['inc'],
            'artist-credits+labels+release-groups+media+recordings');
        return _response({
          'id': releaseId,
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
              'label': {'name': 'Harvest'},
              'catalog-number': 'SHVL 804',
            }
          ],
          'release-group': {
            'id': 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
            'title': 'The Dark Side of the Moon',
          },
          'media': [
            {
              'track-count': 3,
              'format': 'Vinyl',
              'tracks': [
                {
                  'position': 1,
                  'title': 'Speak to Me',
                  'length': 67000,
                  'recording': {'id': 'recording-1'},
                },
                {
                  'position': 2,
                  'title': 'Breathe (In the Air)',
                  'length': 169000,
                },
                {'position': 3, 'title': 'Time', 'length': 425000},
              ]
            }
          ],
          'cover-art-archive': {'artwork': true, 'front': true},
        });
      });

      final envelope = await provider.fetchRelease(releaseId);
      final release = MusicBrainzMusicMapper.releaseCandidate(
        envelope.payload,
        coverArtArchiveBaseUrl: 'https://coverartarchive.org',
        provenance: envelope.provenance,
        attribution: envelope.attribution,
        isHydrated: true,
      );

      expect(envelope.providerItemId, releaseId);
      expect(release.title, 'The Dark Side of the Moon');
      expect(release.publisher, 'Harvest');
      expect(release.catalogNumber, 'SHVL 804');
      expect(release.barcode, '077774600125');
      expect(release.mediums.single.trackCount, 3);
      expect(release.mediums.single.tracks, hasLength(3));
      expect(release.mediums.single.tracks.first.recordingId, 'recording-1');
      expect(envelope.attribution.required, isTrue);
    });

    test('rejects invalid typed MusicBrainz IDs', () async {
      final provider = MusicBrainzProvider();

      expect(
        () => provider.fetchRelease('not-a-musicbrainz-id'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

MusicBrainzProvider _provider(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio();
  dio.httpClientAdapter = _MockHttpAdapter(handler);
  return MusicBrainzProvider(
    httpClient: ProviderHttpClient(
      provider: 'musicbrainz',
      baseUrl: 'https://musicbrainz.org/ws/2',
      dio: dio,
    ),
  );
}

ResponseBody _response(Map<String, dynamic> payload) => ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
