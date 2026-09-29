import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flat Core Music item preserves edition, disc, and track fields', () {
    final item = CatalogMusicItemDto.fromJson({
      'id': 'edition-1',
      'kind': 'music',
      'title': 'The Wall',
      'sort_title': 'Wall, The',
      'artist': 'Pink Floyd',
      'release_date': '1979-11-30',
      'label': 'Harvest',
      'barcode': '0123456789012',
      'discs': [
        {
          'id': 'disc-1',
          'disc_number': 1,
          'title': 'Side A',
          'matrix_number_side_a': 'SHVL 804 A-2',
          'tracks': [
            {
              'id': 'track-1',
              'position': 'A1',
              'position_order': 0,
              'title': 'In the Flesh?',
              'duration_ms': 187000,
            },
          ],
        },
      ],
    });

    expect(item.id, 'edition-1');
    expect(item.title, 'The Wall');
    expect(item.artist, 'Pink Floyd');
    expect(item.label, 'Harvest');
    expect(item.barcode, '0123456789012');
    expect(item.discs.single.discNumber, 1);
    expect(item.discs.single.tracks.single.position, 'A1');
    expect(item.discs.single.tracks.single.positionOrder, 0);
    expect(item.discs.single.tracks.single.durationMs, 187000);

    final proposal = item.toProposalData();
    expect(proposal, isNot(contains('id')));
    expect(proposal, isNot(contains('revision')));
    expect((proposal['discs'] as List).single, containsPair('disc_number', 1));
  });

  test('Music DTO rejects a response for another kind', () {
    expect(
      () => CatalogMusicItemDto.fromJson({
        'id': 'other-1',
        'kind': 'movie',
        'title': 'Wrong kind',
      }),
      throwsFormatException,
    );
  });
}
