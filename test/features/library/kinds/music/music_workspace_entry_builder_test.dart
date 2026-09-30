import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music catalog mapper builds one concrete album with contained discs',
      () {
    final item = MusicCatalogMapper.mapDtoToMusic(
      testCatalogItem(
        id: 'music-album-1',
        kind: 'music',
        title: 'Kinesis',
        payload: {
          'music': {
            'artist': 'Porcupine Tree',
            'label': 'Inside Out',
            'format': 'CD',
            'catalog_number': 'KDCD 1022',
            'barcode': '5099991022',
            'discs': [
              {
                'id': 'disc-1',
                'disc_number': 1,
                'title': 'Main album',
                'tracks': [
                  {
                    'id': 'track-1',
                    'position': '1',
                    'position_order': 1,
                    'title': 'The Start of Something Beautiful',
                    'duration_ms': 447000,
                  },
                ],
              },
            ],
          },
        },
      ),
    );

    expect(item, isA<MusicAlbum>());
    expect(item.id.value, 'music-album-1');
    expect(item.title, 'Kinesis');
    expect(item.artist, 'Porcupine Tree');
    expect(item.publisher, 'Inside Out');
    expect(item.physicalFormatLabel, 'CD');
    expect(item.catalogNumber, 'KDCD 1022');
    expect(item.barcode, '5099991022');
    expect(item.mediums, hasLength(1));
    expect(item.mediums.single.mediumNumber, 1);
    expect(item.mediums.single.tracks.single.position, '1');
    expect(item.mediums.single.tracks.single.title,
        'The Start of Something Beautiful');
  });
}
