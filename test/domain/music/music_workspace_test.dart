import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects one concrete album without an intermediate catalog node', () {
    final album = _album();
    final source = _source(album);

    final dto = const MusicCatalogItemWorkspaceProjector().project(
      source: source,
      entity: const LibraryCatalogItemNodeRef(catalogItemId: 'album-1'),
    );

    expect(dto.title, 'The Wall');
    expect(dto.music.id, const MusicAlbumId('album-1'));
    expect(dto.music.artist, 'Pink Floyd');
    expect(dto.music.mediums, hasLength(1));
    expect(dto.music.tracks, hasLength(2));
    expect(dto.trackCount, 2);
  });

  test('contained disc and track entries follows its album', () {
    final album = MusicAlbum.fromJson({
      'id': 'album-2',
      'title': 'Discovery CD',
      'artist': 'Daft Punk',
      'mediums': [
        {
          'id': 'disc-1',
          'album_id': 'album-2',
          'medium_number': 1,
          'medium_type': 'CD',
          'tracks': [
            {
              'id': 'track-1',
              'medium_id': 'disc-1',
              'position': '1',
              'title': 'One More Time',
            },
          ],
        },
      ],
    });

    expect(album.id.value, 'album-2');
    expect(album.mediums.single.albumId, album.id);
    expect(
        album.mediums.single.tracks.single.mediumId, album.mediums.single.id);
    expect(album.mediums.single.tracks.single.title, 'One More Time');
  });

  test('Music vocabularies project the album catalog fields', () {
    final album = _album();

    expect(MusicVocabularies.genre.valuesFrom!(album), contains('Rock'));
    expect(MusicVocabularies.mediaType.valuesFrom!(album), contains('Vinyl'));
    expect(
      MusicVocabularies.creditRole.valuesFrom!(album),
      contains('Performer'),
    );
    expect(MusicVocabularies.country.valuesFrom!(album), contains('GB'));
  });

  test('Music listening summary is attached to the concrete album item', () {
    final album = _album();
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId.catalogItem,
      id: album.id.value,
    );
    final events = [
      MusicListenEvent(
        id: 'listen-one',
        catalogRef: CatalogItemRef(kind: catalogRef.kind, id: album.id.value),
        listenedAt: DateTime.utc(2026, 1, 2),
      ),
      MusicListenEvent(
        id: 'listen-two',
        catalogRef: CatalogItemRef(kind: catalogRef.kind, id: album.id.value),
        listenedAt: DateTime.utc(2026, 2, 3),
      ),
    ];
    final summary = MusicCatalogItemListeningSummary.fromEvents(
      catalogItemId: album.id.value,
      events: events,
    );
    final source = _source(album, listeningSummary: summary);

    final dto = const MusicCatalogItemWorkspaceProjector().project(
      source: source,
      entity: const LibraryCatalogItemNodeRef(catalogItemId: 'album-1'),
    );

    expect(dto.listenCount, 2);
    expect(dto.lastListened, DateTime.utc(2026, 2, 3));
  });
}

LibraryWorkspaceSource _source(
  MusicAlbum album, {
  MusicCatalogItemListeningSummary? listeningSummary,
}) =>
    LibraryWorkspaceSource(
      itemId: album.id.value,
      catalogData: MusicWorkspaceCatalogData.fromMusic(
        album,
        ref: CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: CatalogEntityTypeId.catalogItem,
          id: album.id.value,
        ),
        listeningSummary: listeningSummary,
      ),
    );

MusicAlbum _album() => MusicAlbum(
      id: const MusicAlbumId('album-1'),
      title: 'The Wall',
      artist: 'Pink Floyd',
      genres: const ['Rock'],
      publisher: 'Harvest',
      countryCode: 'GB',
      mediums: [
        MusicMedium(
          id: const MusicMediumId('disc-1'),
          albumId: const MusicAlbumId('album-1'),
          mediumNumber: 1,
          mediumType: 'Vinyl',
          tracks: [
            MusicTrack(
              id: const MusicTrackId('track-1'),
              mediumId: const MusicMediumId('disc-1'),
              position: 'A1',
              title: 'In the Flesh?',
              durationMs: 187000,
            ),
            MusicTrack(
              id: const MusicTrackId('track-2'),
              mediumId: const MusicMediumId('disc-1'),
              position: 'A2',
              title: 'The Thin Ice',
            ),
          ],
        ),
      ],
      contributions: [
        MusicAlbumContribution(
          id: const MusicAlbumContributionId('contribution-1'),
          albumId: const MusicAlbumId('album-1'),
          personId: 'person-pink-floyd',
          role: 'Performer',
          displayName: 'Pink Floyd',
        ),
      ],
    );
