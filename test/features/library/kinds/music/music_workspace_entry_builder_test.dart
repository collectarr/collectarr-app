import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music work maps metadata into a workspace entry', () {
    final work = MusicCatalogMapper.mapDtoToMusic(
      CatalogItemDto(
        id: 'music-1',
        kind: 'music',
        title: 'Kinesis',
        publisher: 'Inside Out',
        releaseDate: DateTime.utc(1998, 1, 1),
        editions: [
          CatalogEditionDto(
            id: 'edition-1',
            title: 'CD',
            publisher: 'Inside Out',
            upc: '1234567890',
          ),
        ],
        music: const {
          'track_count': 3,
          'catalog_number': 'KDCD 1022',
          'release_status': 'Album',
        },
      ),
    );

    expect(work.work.title, 'Kinesis');
    expect(work.releases, hasLength(1));
    expect(work.releases.first.catalogNumber, 'KDCD 1022');
  });
}
