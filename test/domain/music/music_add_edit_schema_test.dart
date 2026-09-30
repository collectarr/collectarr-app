import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the Music edit schema edits one concrete Catalog Item', () {
    final item = MusicAlbum(
      id: const MusicAlbumId('album-1'),
      title: 'Album',
      artist: 'Artist',
    );
    final draft = MusicAlbumEditDraft.fromAlbum(item);

    expect(musicAlbumEditSchema.title!(item), 'Album / Artist');
    expect(musicAlbumEditSchema.tabs.map((tab) => tab.id), [
      'main',
      'details',
      'personal',
    ]);
    expect(musicAlbumEditSchema.validate!(item, draft), isNull);
    draft.values.title = '';
    expect(musicAlbumEditSchema.validate!(item, draft), 'Title is required');
  });

  test('form updates preserve the disc and track child graph', () {
    final disc = MusicMedium(
      id: const MusicMediumId('disc-1'),
      albumId: const MusicAlbumId('album-1'),
      mediumNumber: 1,
      matrixNumberSideA: 'A1',
      matrixNumberSideB: 'B1',
    );
    final original = MusicAlbum(
      id: const MusicAlbumId('album-1'),
      title: 'Original title',
      artist: 'Original artist',
      mediums: [disc],
    );
    final values = MusicAlbumFormValues.fromAlbum(original)
      ..title = 'Updated title'
      ..artist = 'Updated artist'
      ..genres = ['Rock'];

    final updated = MusicAlbumFormAdapter.update(original, values);

    expect(updated.id, original.id);
    expect(updated.title, 'Updated title');
    expect(updated.artist, 'Updated artist');
    expect(updated.genres, ['Rock']);
    expect(updated.mediums.single.matrixNumberSideA, 'A1');
    expect(updated.mediums.single.matrixNumberSideB, 'B1');
  });

  test('Music transport accepts a flat item with contained discs', () {
    final dto = CatalogMusicItemDto.fromJson({
      'id': 'album-1',
      'kind': 'music',
      'title': 'Album',
      'artist': 'Artist',
      'format': 'Vinyl',
      'discs': [
        {
          'id': 'disc-1',
          'disc_number': 1,
          'matrix_number_side_a': 'A1',
          'tracks': [
            {'id': 'track-1', 'position': '1', 'title': 'Opening'},
          ],
        },
      ],
    });

    expect(dto.discs.single.discNumber, 1);
    expect(dto.discs.single.tracks.single.title, 'Opening');
    expect(
      () => CatalogMusicItemDto.fromJson({
        'id': 'album-1',
        'kind': 'music',
        'title': 'Album',
        'release_group_id': 'group-1',
      }),
      throwsFormatException,
    );
  });
}
