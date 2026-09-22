import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_integration.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/music/stats/music_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('MusicBrainz mapper creates release-group/release/medium/track graph',
      () {
    final group = MusicMusicBrainzMapper.releaseGroupFromNative(
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
    final release = group.primaryRelease!;
    final medium = release.mediums.single;

    expect(group.id.value, startsWith('musicbrainz:'));
    expect(group.artist, 'Pink Floyd');
    expect(release.publisher, 'Harvest');
    expect(release.catalogNumber, 'SHVL 804');
    expect(medium.mediumType, 'Vinyl');
    expect(medium.releaseId, release.id);
    expect(medium.tracks.single.mediumId, medium.id);
    expect(medium.tracks.single.durationMs, 67000);
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
    expect(
        mapped.releaseGroupId.value, startsWith('musicbrainz:release-group:'));
  });

  test('Music hierarchy renders medium containers and track leaves', () {
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
    expect(nodes.single.secondaryLabel, 'Vinyl / 2 tracks');
    expect(nodes.single.children, hasLength(2));
    expect(nodes.single.children.first.level, LibraryHierarchyLevel.leaf);
    expect(nodes.single.children.first.secondaryLabel, '1:01');
    expect(nodes.single.children.first.extras['kind'], 'music_track');
  });

  test('Music owns listening vocabulary and collection statistics', () {
    expect(musicKindTrackingProfile, same(musicTrackingProfile));
    expect(musicTrackingProfile.name, 'Music');
    expect(musicTrackingProfile.normalizeStorageValue('completed'), 'Listened');

    final entries = [
      _musicSource('group-1', 'Album One', 'Pink Floyd', 'Vinyl', 10),
      _musicSource('group-2', 'Album Two', 'Pink Floyd', 'CD', 5),
    ];

    expect(MusicStatsCapability.totalTracks(entries), 15);
    expect(MusicStatsCapability.totalReleaseGroups(entries), 2);
    expect(MusicStatsCapability.totalReleases(entries), 2);
    expect(MusicStatsCapability.countArtists(entries), {'Pink Floyd': 2});
    expect(MusicStatsCapability.countGenres(entries), {
      'Progressive Rock': 1,
      'Rock': 2,
    });
    expect(MusicStatsCapability.countFormats(entries), {'Vinyl': 1, 'CD': 1});
    expect(MusicStatsCapability.countLabels(entries), {'Harvest': 2});
  });

  test('Music listening aggregates feed workspace-aware stats', () {
    final source = _musicSource('group-listens', 'Album', 'Artist', 'Vinyl', 2);
    final catalog = source.catalogData! as MusicWorkspaceCatalogData;
    final release = catalog.release!;
    final releaseRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: const CatalogEntityTypeId('release'),
      id: release.id.value,
      rootId: catalog.music.id.value,
    );
    final events = [
      MusicListenEvent(
        id: 'listen-1',
        releaseRef: releaseRef,
        listenedAt: DateTime.utc(2026, 1, 5),
      ),
      MusicListenEvent(
        id: 'listen-2',
        releaseRef: releaseRef,
        listenedAt: DateTime.utc(2026, 2, 5),
      ),
    ];
    final summary = MusicReleaseGroupTrackingSummary.fromEvents(
      releaseGroupId: catalog.music.id.value,
      events: events,
      releaseIds: catalog.music.releases.map((entry) => entry.id.value),
    );
    final listenedSource = LibraryWorkspaceSource(
      itemId: source.itemId,
      catalogData: catalog.copyWith(listeningSummary: summary),
    );

    expect(MusicStatsCapability.totalListens([listenedSource]), 2);
    expect(MusicStatsCapability.countMostListenedGroups([listenedSource]),
        {'Album': 2});
    expect(
      MusicStatsCapability.countMostListenedReleases([listenedSource]).values,
      contains(2),
    );
    expect(MusicStatsCapability.countListeningByMonth([listenedSource]), {
      '2026-01': 1,
      '2026-02': 1,
    });
  });
}

LibraryWorkspaceSource _musicSource(
  String id,
  String title,
  String artist,
  String mediumType,
  int trackCount,
) {
  final release = MusicRelease(
    id: MusicReleaseId('$id-release'),
    releaseGroupId: MusicReleaseGroupId(id),
    title: title,
    publisher: 'Harvest',
    releaseType: mediumType,
    mediums: [
      MusicMedium(
        id: MusicMediumId('$id-medium'),
        releaseId: MusicReleaseId('$id-release'),
        mediumNumber: 1,
        mediumType: mediumType,
        trackCount: trackCount,
      ),
    ],
  );
  final group = MusicReleaseGroup(
    id: MusicReleaseGroupId(id),
    title: title,
    artist: artist,
    genres: id == 'group-1' ? ['Progressive Rock', 'Rock'] : ['Rock'],
    releases: [release],
  );
  final item = testCatalogItem(
    id: id,
    kind: 'music',
    title: title,
    payload: group.toJson(),
  ).withKindMetadata(group);
  return testLibraryWorkspaceSource(
    itemId: id,
    kind: 'music',
    catalogData: MusicWorkspaceCatalogData.fromMusic(
      group,
      ref: item.catalogRef,
      release: release,
    ),
  );
}
