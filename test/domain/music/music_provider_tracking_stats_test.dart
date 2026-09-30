import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/music/stats/music_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('Music hierarchy renders medium containers and track leaves', () {
    final releaseId = MusicReleaseId('album-release');
    final mediumId = MusicMediumId('album-medium');
    final release = MusicRelease(
      id: releaseId,
      title: 'Album',
      mediums: [
        MusicMedium(
          id: mediumId,
          releaseId: releaseId,
          mediumNumber: 1,
          mediumType: 'Vinyl',
          tracks: [
            MusicTrack(
              id: MusicTrackId('track-1'),
              mediumId: mediumId,
              position: '1',
              title: 'Opening',
              durationMs: 61000,
            ),
            MusicTrack(
              id: MusicTrackId('track-2'),
              mediumId: mediumId,
              position: '2',
              title: 'Closer',
              durationMs: 122000,
            ),
          ],
        ),
      ],
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
      _musicSource('album-1', 'Album One', 'Pink Floyd', 'Vinyl', 10),
      _musicSource('album-2', 'Album Two', 'Pink Floyd', 'CD', 5),
    ];

    expect(MusicStatsCapability.totalTracks(entries), 15);
    expect(MusicStatsCapability.totalCatalogItems(entries), 2);
    expect(MusicStatsCapability.totalMedia(entries), 2);
    expect(MusicStatsCapability.countArtists(entries), {'Pink Floyd': 2});
    expect(MusicStatsCapability.countGenres(entries), {
      'Progressive Rock': 1,
      'Rock': 2,
    });
    expect(MusicStatsCapability.countFormats(entries), {'Vinyl': 1, 'CD': 1});
    expect(MusicStatsCapability.countLabels(entries), {'Harvest': 2});
  });

  test('Music listening aggregates feed workspace-aware stats', () {
    final source = _musicSource('album-listens', 'Album', 'Artist', 'Vinyl', 2);
    final catalog = source.catalogData! as MusicWorkspaceCatalogData;
    final catalogRef = CatalogItemRef(
      kind: CatalogMediaKind.music,
      id: catalog.music.id.value,
    );
    final events = [
      MusicListenEvent(
        id: 'listen-1',
        catalogRef: catalogRef,
        listenedAt: DateTime.utc(2026, 1, 5),
      ),
      MusicListenEvent(
        id: 'listen-2',
        catalogRef: catalogRef,
        listenedAt: DateTime.utc(2026, 2, 5),
      ),
    ];
    final summary = MusicCatalogItemListeningSummary.fromEvents(
      catalogItemId: catalog.music.id.value,
      events: events,
    );
    final listenedSource = LibraryWorkspaceSource(
      itemId: source.itemId,
      catalogData: catalog.copyWith(listeningSummary: summary),
    );

    expect(MusicStatsCapability.totalListens([listenedSource]), 2);
    expect(MusicStatsCapability.countMostListenedItems([listenedSource]),
        {'Album': 2});
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
  final musicItem = MusicRelease(
    id: MusicReleaseId(id),
    title: title,
    artist: artist,
    publisher: 'Harvest',
    releaseType: mediumType,
    mediums: [
      MusicMedium(
        id: MusicMediumId('$id-medium'),
        releaseId: MusicReleaseId(id),
        mediumNumber: 1,
        mediumType: mediumType,
        trackCount: trackCount,
      ),
    ],
  );
  final musicWithGenres = MusicRelease.fromJson({
    ...musicItem.toJson(),
    'genres': id == 'album-1' ? ['Progressive Rock', 'Rock'] : ['Rock'],
  });
  final catalogItem = testCatalogItem(
    id: id,
    kind: 'music',
    title: title,
    payload: musicWithGenres.toJson(),
  ).withKindMetadata(musicWithGenres);
  return testLibraryWorkspaceSource(
    itemId: id,
    kind: 'music',
    catalogData: MusicWorkspaceCatalogData.fromMusic(
      musicWithGenres,
      ref: catalogItem.catalogRef,
    ),
  );
}
