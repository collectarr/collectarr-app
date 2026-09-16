import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/release/music_release_projection_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects a typed placeholder when a catalog snapshot is missing', () {
    final source = LibraryWorkspaceSource(
      itemId: 'missing-group',
      catalogSummary: CatalogDisplaySummary.root(
        kind: CatalogMediaKind.music,
        id: 'missing-group',
        title: 'Recovered album',
      ),
    );

    final dto = const MusicWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'missing-group'),
    );

    expect(dto.title, 'Recovered album');
    expect(dto.music.id.value, 'missing-group');
    expect(dto.release.releaseGroupId.value, 'missing-group');
  });

  test('maps a canonical Music release group into a workspace release', () {
    final group = MusicReleaseGroup(
      id: MusicReleaseGroupId('group-1'),
      title: 'The Wall',
      artist: 'Pink Floyd',
      genres: ['Rock'],
      releases: [
        MusicRelease(
          id: MusicReleaseId('release-1'),
          releaseGroupId: MusicReleaseGroupId('group-1'),
          title: 'The Wall',
          mediums: [
            MusicMedium(
              id: MusicMediumId('medium-1'),
              releaseId: MusicReleaseId('release-1'),
              mediumNumber: 1,
              mediumType: 'Vinyl',
              tracks: [
                MusicTrack(
                  id: MusicTrackId('track-1'),
                  mediumId: MusicMediumId('medium-1'),
                  position: 'A1',
                  title: 'In the Flesh?',
                  durationMs: 187000,
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final release = MusicWorkspaceCatalogData.fromMusic(group).release;

    expect(release.id, const MusicReleaseId('release-1'));
    expect(release.releaseGroupId, group.id);
    expect(release.title, 'The Wall');
    expect(release.mediums.single.mediumType, 'Vinyl');
    expect(
        release.mediums.single.tracks.single.id, const MusicTrackId('track-1'));
    expect(release.tracks.single.durationMs, 187000);
  });

  test('selects a concrete release without imposing video hierarchy', () {
    final group = MusicReleaseGroup.fromJson({
      'id': 'group-2',
      'title': 'Discovery',
      'artist': 'Daft Punk',
      'releases': [
        {
          'id': 'release-cd',
          'release_group_id': 'group-2',
          'title': 'Discovery CD',
          'release_type': 'Album',
          'mediums': <Map<String, dynamic>>[],
        },
      ],
    });
    final release =
        MusicWorkspaceCatalogData.fromMusic(group).releaseForSummary(
      const LibraryWorkspaceReleaseSummary(
        id: 'release-cd',
        title: 'Discovery CD',
      ),
    );

    expect(release.id.value, 'release-cd');
    expect(release.releaseGroupId.value, 'group-2');
    expect(release.title, 'Discovery CD');
    expect(release.mediums, isEmpty);
  });

  test('Music vocabularies project canonical release-group fields', () {
    final group = MusicReleaseGroup(
      id: MusicReleaseGroupId('group-vocab'),
      title: 'Kind of Blue',
      artist: 'Miles Davis',
      genres: ['Jazz'],
      releases: [
        MusicRelease(
          id: MusicReleaseId('release-vocab'),
          releaseGroupId: MusicReleaseGroupId('group-vocab'),
          title: 'Kind of Blue',
          publisher: 'Columbia Records',
          countryCode: 'US',
          mediums: [
            MusicMedium(
              id: MusicMediumId('medium-vocab'),
              releaseId: MusicReleaseId('release-vocab'),
              mediumNumber: 1,
              mediumType: 'Vinyl LP',
              tracks: [
                MusicTrack(
                  id: MusicTrackId('track-vocab'),
                  mediumId: MusicMediumId('medium-vocab'),
                  position: '1',
                  title: 'So What',
                ),
              ],
            ),
          ],
          contributions: [
            MusicReleaseContribution(
              id: MusicReleaseContributionId('contribution-1'),
              releaseId: MusicReleaseId('release-vocab'),
              personId: 'person-miles-davis',
              role: 'Performer',
              displayName: 'Miles Davis',
            ),
          ],
        ),
      ],
    );

    expect(MusicVocabularies.genre.valuesFrom!(group), contains('Jazz'));
    expect(
        MusicVocabularies.mediaType.valuesFrom!(group), contains('Vinyl LP'));
    expect(
        MusicVocabularies.creditRole.valuesFrom!(group), contains('Performer'));
    expect(MusicVocabularies.country.valuesFrom!(group), contains('US'));
  });

  test('release workspace keeps tracking state scoped to each release', () {
    final groupId = MusicReleaseGroupId('group-tracking');
    final groupRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId.root,
      id: groupId.value,
    );
    final releaseOne = MusicRelease(
      id: const MusicReleaseId('release-one'),
      releaseGroupId: groupId,
      title: 'Release One',
    );
    final releaseTwo = MusicRelease(
      id: const MusicReleaseId('release-two'),
      releaseGroupId: groupId,
      title: 'Release Two',
    );
    final group = MusicReleaseGroup(
      id: groupId,
      title: 'Tracked Group',
      releases: [releaseOne, releaseTwo],
    );
    final releaseOneRef = musicReleaseRefForRoot(groupRef, releaseOne.id.value);
    final releaseTwoRef = musicReleaseRefForRoot(groupRef, releaseTwo.id.value);
    final releaseOneTracking = TrackingSummary(
      id: 'tracking-one',
      catalogRef: releaseOneRef,
      status: MediaTrackingStatus.completed,
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final source = LibraryWorkspaceSource(
      itemId: groupId.value,
      catalogData: MusicWorkspaceCatalogData.fromMusic(
        group,
        ref: groupRef,
      ),
      trackingSummary: releaseOneTracking,
      trackingSummaries: [releaseOneTracking],
    );

    final items = const MusicReleaseProjectionCapability<MusicWorkspaceDto>()
        .projectReleases(
      source: source,
      type: const MusicRegistration(),
      projector: const MusicWorkspaceProjector(),
      customFieldDefinitions: const [],
      customFieldValuesByDefinitionByItem: const {},
      customFieldValuesByItem: const {},
    );

    expect(items, hasLength(2));
    expect(items[0].dto.personal.isTracked, isTrue);
    expect(items[0].dto.personal.trackingStatus, 'Completed');
    expect(items[1].dto.personal.isTracked, isFalse);
    expect(items[1].dto.personal.trackingStatus, isNull);
    expect(source.trackingSummaryFor(releaseTwoRef), isNull);
  });

  test('Music workspace projects derived group and release listening values',
      () {
    final groupId = MusicReleaseGroupId('group-listening');
    final groupRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId.root,
      id: groupId.value,
    );
    final releaseOne = MusicRelease(
      id: const MusicReleaseId('release-listening-one'),
      releaseGroupId: groupId,
      title: 'Release One',
    );
    final releaseTwo = MusicRelease(
      id: const MusicReleaseId('release-listening-two'),
      releaseGroupId: groupId,
      title: 'Release Two',
    );
    final group = MusicReleaseGroup(
      id: groupId,
      title: 'Listened Group',
      releases: [releaseOne, releaseTwo],
    );
    final releaseOneRef = musicReleaseRefForRoot(groupRef, releaseOne.id.value);
    final events = [
      MusicListenEvent(
        id: 'listen-one',
        targetRef: releaseOneRef,
        releaseGroupId: groupId.value,
        releaseId: releaseOne.id.value,
        listenedAt: DateTime.utc(2026, 1, 2),
      ),
      MusicListenEvent(
        id: 'listen-two',
        targetRef: releaseOneRef,
        releaseGroupId: groupId.value,
        releaseId: releaseOne.id.value,
        listenedAt: DateTime.utc(2026, 2, 3),
      ),
    ];
    final source = LibraryWorkspaceSource(
      itemId: groupId.value,
      catalogData: MusicWorkspaceCatalogData.fromMusic(
        group,
        ref: groupRef,
        listeningSummary: MusicReleaseGroupTrackingSummary.fromEvents(
          releaseGroupId: groupId.value,
          events: events,
          releaseIds: group.releases.map((release) => release.id.value),
        ),
      ),
    );

    final dto = const MusicWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'group-listening'),
    );

    expect(dto.aggregateListenCount, 2);
    expect(dto.listenedReleaseCount, 1);
    expect(dto.aggregateLastListened, DateTime.utc(2026, 2, 3));
    expect(dto.listenCount, 2);
    expect(dto.lastListened, DateTime.utc(2026, 2, 3));
  });
}
