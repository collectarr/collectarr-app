import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
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
      'genres': <String>[],
      'studios': <String>[],
      'extra': <String>[],
      'conductors': <Map<String, Object?>>[],
      'choruses': <String>[],
      'compositions': <String>[],
      'orchestras': <String>[],
      'songwriters': <Map<String, Object?>>[],
      'producers': <Map<String, Object?>>[],
      'engineers': <Map<String, Object?>>[],
      'musicians': <Map<String, Object?>>[],
      'external_links': <Map<String, Object?>>[],
      'composers': [
        {
          'id': 'composer-credit-1',
          'person_id': 'person-1',
          'name': 'Composer Name',
          'sort_name': 'Name, Composer',
          'sequence': 1,
        },
      ],
      'release_date': {'year': 1998, 'month': 11},
      'discs': [
        {
          'id': 'disc-1',
          'disc_number': 1,
          'title': 'Side One',
          'sound_types': <String>[],
          'matrix_number_side_a': 'MATRIX-A',
          'tracks': [
            {
              'id': 'track-1',
              'position': 'A1',
              'position_order': 0,
              'title': 'Opening track',
              'artist': 'Guest artist',
              'duration_ms': 186000,
              'is_header': false,
              'indent_level': 0,
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
    expect(encoded['release_date'], {'year': 1998, 'month': 11});
    expect(disc['id'], 'disc-1');
    expect(disc['title'], 'Side One');
    expect(disc['matrix_number_side_a'], 'MATRIX-A');
    expect(track['id'], 'track-1');
    expect(track['position'], 'A1');
    expect(track['position_order'], 1);
    expect(track['artist'], 'Guest artist');
    expect(track['duration_ms'], 186000);
  });

  test('Music edit persists a changed disc format through the catalog mapper',
      () {
    final source = CatalogItemDto.fromJson({
      'id': 'album-format',
      'kind': 'music',
      'title': 'Format test',
      'discs': [
        {
          'id': 'disc-1',
          'disc_number': 1,
          'format': 'Vinyl (12" LP)',
          'format_family': 'vinyl',
          'sound_types': <String>[],
          'tracks': [],
        }
      ],
      'revision': 1,
      'artist_credits': <Map<String, Object?>>[],
      'genres': <String>[],
      'studios': <String>[],
      'extra': <String>[],
      'composers': <Map<String, Object?>>[],
      'conductors': <Map<String, Object?>>[],
      'choruses': <String>[],
      'compositions': <String>[],
      'orchestras': <String>[],
      'songwriters': <Map<String, Object?>>[],
      'producers': <Map<String, Object?>>[],
      'engineers': <Map<String, Object?>>[],
      'musicians': <Map<String, Object?>>[],
      'external_links': <Map<String, Object?>>[],
    });
    final original = MusicCatalogMapper.mapMetadataItemToMusic(source);
    final disc = original.discs.first;
    final updatedDisc = MusicDisc(
      id: disc.id,
      discNumber: disc.discNumber,
      format: 'CD',
      formatFamily: MusicDiscFormatFamily.cd,
    );
    final values = MusicAlbumFormValues.fromAlbum(original);
    final edited = MusicAlbumFormAdapter.update(
      original,
      values,
      discs: [updatedDisc],
    );
    final encoded = MusicCatalogMapper.toCatalogItemDto(edited);

    final discs = encoded.kindData['discs'] as List;
    expect((discs.first as Map)['format'], 'CD');
    expect((discs.first as Map)['format_family'], 'cd');
  });
}
