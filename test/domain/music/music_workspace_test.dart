import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_mapper.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a Music catalog payload into a typed workspace release graph', () {
    final item = CatalogItem(
      identity: const LibraryItemIdentity(
        id: 'music-item-1',
        mediaKind: CatalogMediaKind.music,
      ),
      kindMetadata: const MusicCatalogMetadata(
        title: 'The Wall',
        artist: 'Pink Floyd',
        genres: ['Rock'],
        tracks: [
          CatalogTrackDto(
            title: 'In the Flesh?',
            position: 'A1',
            durationSeconds: 187,
          ),
        ],
      ),
    );

    final release = MusicWorkspaceMapper.fromCatalogItem(item);

    expect(release, isA<MusicRelease>());
    expect(release.id.value, 'music-item-1');
    expect(release.title, 'The Wall');
    expect(release.artist, 'Pink Floyd');
    expect(release.genres, ['Rock']);
    expect(release.media.single.mediaNumber, 1);
    expect(release.media.single.tracks.single.id.value,
        'music-item-1:media:1:track:A1');
    expect(release.media.single.tracks.single.durationMs, 187000);
  });

  test('maps a selected catalog edition without imposing video semantics', () {
    final item = CatalogItem(
      identity: const LibraryItemIdentity(
        id: 'music-item-2',
        mediaKind: CatalogMediaKind.music,
      ),
      kindMetadata: const MusicCatalogMetadata(
        title: 'Discovery',
        artist: 'Daft Punk',
      ),
    );
    final edition = CatalogEditionDto(
      id: 'release-vinyl',
      title: 'Discovery — Vinyl',
      physicalFormat: 'vinyl',
      region: 'FR',
      discs: [
        CatalogDiscDto(
          discNumber: 1,
          name: 'Side A',
          tracks: [
            CatalogTrackDto(title: 'One More Time', position: 'A1'),
          ],
        ),
      ],
    );

    final release = MusicWorkspaceMapper.fromCatalogItem(
      item,
      releaseId: edition.id,
      edition: edition,
    );

    expect(release.id.value, 'release-vinyl');
    expect(release.title, 'Discovery — Vinyl');
    expect(release.media.single.mediaType, 'vinyl');
    expect(release.media.single.title, 'Side A');
    expect(release.tracks.single.title, 'One More Time');
  });

  test('Music vocabularies project genres, media types, credits, and countries',
      () {
    const metadata = MusicCatalogMetadata(
      title: 'Kind of Blue',
      genres: ['Jazz'],
      credits: [MusicCredit(name: 'Miles Davis', role: 'Performer')],
      physicalFormatLabel: 'Vinyl LP',
      country: 'US',
    );

    expect(MusicVocabularies.genre.valuesFrom!(metadata), contains('Jazz'));
    expect(MusicVocabularies.mediaType.valuesFrom!(metadata),
        contains('Vinyl LP'));
    expect(MusicVocabularies.creditRole.valuesFrom!(metadata),
        contains('Performer'));
    expect(MusicVocabularies.country.valuesFrom!(metadata), contains('US'));
  });
}
