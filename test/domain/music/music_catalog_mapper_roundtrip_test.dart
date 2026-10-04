import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music mapper preserves album, credit, disc, and track identities', () {
    final source = CatalogItemDto.fromJson({
      'id': 'album-1',
      'kind': 'music',
      'revision': 7,
      'title': 'Album title',
      'artist': 'Display artist',
      'artist_credits': [
        {
          'id': 'credit-1',
          'name': 'The Artist',
          'sort_name': 'Artist, The',
          'artist_id': 'artist-1',
          'join_phrase': ' & ',
          'sequence': 1,
        },
      ],
      'composers': [
        {
          'id': 'composer-credit-1',
          'person_id': 'person-1',
          'name': 'Composer Name',
          'sort_name': 'Name, Composer',
        },
      ],
      'release_date': '1998-11',
      'discs': [
        {
          'id': 'disc-1',
          'disc_number': 1,
          'title': 'Side One',
          'matrix_number_side_a': 'MATRIX-A',
          'tracks': [
            {
              'id': 'track-1',
              'position': 'A1',
              'position_order': 0,
              'title': 'Opening track',
              'artist': 'Guest artist',
              'duration_ms': 186000,
            },
          ],
        },
      ],
    });

    final album = MusicCatalogMapper.mapMetadataItemToMusic(source);
    final output = MusicCatalogMapper.toCatalogItemDto(album);
    final encoded = output.kindData;
    final artistCredits = encoded['artist_credits'] as List;
    final composers = encoded['composers'] as List;
    final disc = (encoded['discs'] as List).single as Map;
    final track = (disc['tracks'] as List).single as Map;

    expect(output.id, 'album-1');
    expect(encoded['revision'], 7);
    expect(encoded['artist'], 'Display artist');
    expect(artistCredits.single['id'], 'credit-1');
    expect(artistCredits.single['sort_name'], 'Artist, The');
    expect(composers.single['sort_name'], 'Name, Composer');
    expect(encoded['release_date'], '1998-11');
    expect(disc['id'], 'disc-1');
    expect(disc['title'], 'Side One');
    expect(disc['matrix_number_side_a'], 'MATRIX-A');
    expect(track['id'], 'track-1');
    expect(track['position'], 'A1');
    expect(track['position_order'], 0);
    expect(track['artist'], 'Guest artist');
    expect(track['duration_ms'], 186000);
  });

  test('Music edit persists a changed format through the catalog mapper', () {
    final source = CatalogItemDto.fromJson({
      'id': 'album-format',
      'kind': 'music',
      'title': 'Format test',
      'format': 'Vinyl (12" LP)',
      'discs': [],
    });
    final original = MusicCatalogMapper.mapMetadataItemToMusic(source);
    final values = MusicAlbumFormValues.fromAlbum(original)
      ..physicalFormat = 'CD'
      ..physicalFormatLabel = 'CD';

    final edited = MusicAlbumFormAdapter.update(original, values);
    final encoded = MusicCatalogMapper.toCatalogItemDto(edited);

    expect(encoded.kindData['format'], 'CD');
  });
}
