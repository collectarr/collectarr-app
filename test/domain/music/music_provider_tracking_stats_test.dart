import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_integration.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_tracking.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/stats/music_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('MusicBrainz mapper owns a typed release/media/track graph', () {
    final release = MusicMusicBrainzMapper.fromNative(
      MusicBrainzRelease.fromJson({
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'title': 'The Dark Side of the Moon',
        'date': '1973-03-01',
        'country': 'GB',
        'artist-credit': [
          {
            'artist': {
              'id': '83d91898-7763-47d7-b03b-b92132375c47',
              'name': 'Pink Floyd',
            },
          },
        ],
        'label-info': [
          {
            'catalog-number': 'SHVL 804',
            'label': {'name': 'Harvest'},
          },
        ],
        'media': [
          {
            'format': 'Vinyl',
            'tracks': [
              {'position': 1, 'title': 'Speak to Me', 'length': 67000},
            ],
          },
        ],
      }),
    );

    expect(release.id.value, startsWith('musicbrainz:'));
    expect(release.artist, 'Pink Floyd');
    expect(release.publisher, 'Harvest');
    expect(release.catalogNumber, 'SHVL 804');
    expect(release.media, hasLength(1));
    expect(release.media.single.releaseId, release.id);
    expect(release.tracks.single.mediaId, release.media.single.id);
    expect(release.tracks.single.durationMs, 67000);
  });

  test('MusicBrainz envelope mapper groups normalized tracks by media', () {
    final release = MusicMusicBrainzMapper.fromEnvelope(
      _envelope(
        normalized: {
          'title': 'Selected Ambient Works',
          'artist': 'Aphex Twin',
          'genres': ['Electronic'],
          'formats': ['CD'],
          'tracks': [
            {
              'disc_number': 1,
              'position': 1,
              'title': 'Xtal',
              'duration_seconds': 277,
            },
            {
              'disc_number': 2,
              'position': 1,
              'title': 'Pulsewidth',
              'duration_seconds': 250,
            },
          ],
        },
      ),
    );

    expect(release.id.value, 'musicbrainz:musicbrainz-release-1');
    expect(release.media.map((media) => media.mediaNumber), [1, 2]);
    expect(release.media[1].mediaType, 'CD');
    expect(release.media[0].tracks.single.durationMs, 277000);
  });

  test('MusicBrainz mapper rejects non-Music envelopes', () {
    expect(
      () => MusicMusicBrainzMapper.fromEnvelope(_envelope(kind: 'anime')),
      throwsA(isA<StateError>()),
    );
  });

  test('Music integration exposes provider mapping and forces Music kind', () {
    final integration = MusicMusicBrainzIntegration();
    final mapped = integration.mapNative(
      MusicBrainzRelease.fromJson({
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'title': 'Album',
      }),
    );
    expect(mapped.id.value, startsWith('musicbrainz:'));
  });

  test('Music hierarchy renders media containers and track leaves', () {
    final release = MusicMusicBrainzMapper.fromNative(
      MusicBrainzRelease.fromJson({
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'title': 'Album',
        'media': [
          {
            'format': 'Vinyl',
            'tracks': [
              {'position': 1, 'title': 'Opening', 'length': 61000},
              {'position': 2, 'title': 'Closer', 'length': 122000},
            ],
          },
        ],
      }),
    );

    final nodes = MusicHierarchyMapper.toLibraryNodes(release);
    expect(nodes, hasLength(1));
    expect(nodes.single.level, LibraryHierarchyLevel.container);
    expect(nodes.single.secondaryLabel, 'Vinyl Â· 2 tracks');
    expect(nodes.single.children, hasLength(2));
    expect(nodes.single.children.first.level, LibraryHierarchyLevel.leaf);
    expect(nodes.single.children.first.secondaryLabel, '1:01');
    expect(nodes.single.children.first.metadata['kind'], 'music_track');
  });

  test('Music tracking uses release/media/track scope and round-trips', () {
    final tracking = MusicTracking(
      releaseId: const MusicReleaseId('release-1'),
      mediaId: const MusicMediaId('media-1'),
      trackId: const MusicTrackId('track-1'),
      status: 'Listening',
      playCount: 4,
      timesCompleted: 2,
      lastListenedAt: DateTime.utc(2026, 8, 20),
    );

    final decoded = MusicTracking.fromJson(tracking.toJson());
    expect(decoded.releaseId.value, 'release-1');
    expect(decoded.mediaId?.value, 'media-1');
    expect(decoded.trackId?.value, 'track-1');
    expect(decoded.playCount, 4);
    expect(decoded.timesCompleted, 2);
    expect(decoded.lastListenedAt, DateTime.utc(2026, 8, 20));
  });

  test('Music owns listening vocabulary and collection statistics', () {
    expect(musicKindModule.trackingProfile, same(musicTrackingProfile));
    expect(musicTrackingProfile.name, 'Music');
    expect(
      musicTrackingProfile.normalizeStorageValue('completed'),
      'Listened',
    );

    final entries = [
      testShelfEntry(
        itemId: 'music-1',
        kind: 'music',
        catalogItem: testCatalogItem(
          id: 'music-1',
          kind: 'music',
          title: 'Album One',
          payload: const {
            'artist': 'Pink Floyd',
            'track_count': 10,
            'physical_format': 'Vinyl',
            'record_label': 'Harvest',
            'genres': ['Progressive Rock', 'Rock'],
          },
        ),
      ),
      testShelfEntry(
        itemId: 'music-2',
        kind: 'music',
        catalogItem: testCatalogItem(
          id: 'music-2',
          kind: 'music',
          title: 'Album Two',
          payload: const {
            'artist': 'Pink Floyd',
            'track_count': 5,
            'physical_format': 'CD',
            'record_label': 'Harvest',
            'genres': ['Rock'],
          },
        ),
      ),
    ];

    expect(MusicStatsCapability.totalTracks(entries), 15);
    expect(MusicStatsCapability.countArtists(entries), {'Pink Floyd': 2});
    expect(MusicStatsCapability.countGenres(entries), {
      'Progressive Rock': 1,
      'Rock': 2,
    });
    expect(MusicStatsCapability.countFormats(entries), {'Vinyl': 1, 'CD': 1});
    expect(MusicStatsCapability.countLabels(entries), {'Harvest': 2});
  });
}

NormalizedProviderEnvelopeV1 _envelope({
  String kind = 'music',
  Map<String, dynamic> normalized = const {},
}) {
  return NormalizedProviderEnvelopeV1(
    provider: 'musicbrainz',
    providerItemId: 'musicbrainz-release-1',
    kind: kind,
    normalized: normalized,
    provenance: const ProviderProvenance(fetchedAt: '2026-01-01T00:00:00Z'),
    images: const [],
    attribution: const ProviderAttribution(required: false),
  );
}
