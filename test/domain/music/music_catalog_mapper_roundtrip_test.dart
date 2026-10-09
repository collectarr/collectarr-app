import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music v2 mapper preserves nested album, disc, credit, and track IDs',
      () {
    final source = CatalogItemDto.fromJson({
      'id': 'album-1',
      'kind': 'music',
      'revision': 7,
      'title': 'Album title',
      'artist': 'Display artist',
      'artist_credits': [
        {
          'id': 'artist-credit-1',
          'name': 'The Artist',
          'sort_name': 'Artist, The',
          'artist_id': 'artist-1',
          'join_phrase': ' & ',
          'sequence': 1,
        },
      ],
      'original_release_date': {'year': 1997},
      'release_date': {'year': 1998, 'month': 11},
      'label': 'Example Label',
      'barcode': '1234567890',
      'catalog_number': 'EX 001',
      'genres': ['Jazz'],
      'packaging': 'Digipak',
      'country': 'US',
      'extra': ['Remastered'],
      'box_set': 'Deluxe Edition',
      'credits': [
        {
          'id': 'album-credit-1',
          'name': 'Album Producer',
          'role': 'Producer',
          'sequence': 1,
          'instruments': <String>[],
        },
      ],
      'external_links': <Map<String, Object?>>[],
      'discs': [
        {
          'id': 'disc-1',
          'disc_number': 1,
          'title': 'Side One',
          'format_family': 'opticalDisc',
          'format': 'SHM-CD',
          'sound_types': ['Stereo'],
          'recording_date': {'year': 2025},
          'recording_locations': ['Abbey Road'],
          'is_live': false,
          'spars_code': 'DDD',
          'credits': [
            {
              'id': 'disc-credit-1',
              'name': 'Disc Producer',
              'role': 'Producer',
              'sequence': 1,
              'instruments': <String>[],
            },
          ],
          'tracks': [
            {
              'id': 'track-1',
              'position': 'A1',
              'position_order': 1,
              'title': 'Opening track',
              'artist': 'Guest artist',
              'composition': 'Opening Work',
              'duration_ms': 186000,
              'is_header': false,
              'parent_header_id': null,
              'indent_level': 0,
            },
          ],
        },
      ],
    });

    final album = MusicCatalogMapper.mapMetadataItemToMusic(source);
    final encoded = MusicCatalogMapper.toCatalogItemDto(album).kindData;
    final artistCredits =
        (encoded['artist_credits'] as List).cast<Map<String, dynamic>>();
    final albumCredits =
        (encoded['credits'] as List).cast<Map<String, dynamic>>();
    final disc = (encoded['discs'] as List).cast<Map<String, dynamic>>().single;
    final discCredits = (disc['credits'] as List).cast<Map<String, dynamic>>();
    final track = (disc['tracks'] as List).cast<Map<String, dynamic>>().single;

    expect(encoded['revision'], 7);
    expect(encoded['artist'], 'Display artist');
    expect(artistCredits.single['id'], 'artist-credit-1');
    expect(artistCredits.single['sort_name'], 'Artist, The');
    expect(albumCredits.single['id'], 'album-credit-1');
    expect(discCredits.single['id'], 'disc-credit-1');
    expect(disc['recording_date'], {'year': 2025});
    expect(disc['recording_locations'], ['Abbey Road']);
    expect(disc['spars_code'], 'DDD');
    expect(disc['format_family'], 'opticalDisc');
    expect(track['id'], 'track-1');
    expect(track['position'], 'A1');
    expect(track['position_order'], 1);
    expect(track['composition'], 'Opening Work');
    expect(track['duration_ms'], 186000);
  });

  test('Music edits preserve disc-scoped format and recording ownership', () {
    final original = MusicAlbum(
      id: const CatalogItemRef(
          kind: CatalogMediaKind.music, id: 'album-format'),
      title: 'Format test',
      discs: [
        MusicDisc(
          id: const MusicDiscId('disc-1'),
          discNumber: 1,
          format: 'CD',
          formatFamily: MusicDiscFormatFamily.opticalDisc,
          recordingLocations: const ['Studio A'],
          credits: [
            MusicCredit(
              id: const MusicCreditId('credit-1'),
              name: 'Jane Doe',
              role: 'Producer',
              sequence: 1,
            ),
          ],
        ),
      ],
    );
    final draft = MusicAlbumEditDraft.fromAlbum(original);
    draft.discList.updateDiscFormat(
      const MusicDiscId('disc-1'),
      'SHM-CD',
      formatFamily: MusicDiscFormatFamily.opticalDisc,
    );
    draft.discList.addDisc(
      format: 'Vinyl (12" LP)',
      formatFamily: MusicDiscFormatFamily.vinyl,
    );

    final encoded = MusicCatalogMapper.toCatalogItemDto(draft.toAlbum());
    final discs = encoded.kindData['discs'] as List;
    expect((discs[0] as Map)['format'], 'SHM-CD');
    expect((discs[0] as Map)['format_family'], 'opticalDisc');
    expect((discs[0] as Map)['recording_locations'], ['Studio A']);
    expect((discs[0] as Map)['credits'], hasLength(1));
    expect((discs[1] as Map)['format_family'], 'vinyl');
    expect(encoded.kindData, isNot(contains('recording_date')));
    expect(encoded.kindData, isNot(contains('spars_code')));
  });
}
