import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music catalog mapper returns the canonical release-group graph', () {
    final group = MusicCatalogMapper.mapDtoToMusic(
      testCatalogItem(
        id: 'music-group-1',
        kind: 'music',
        title: 'Kinesis',
        payload: {
          'release_group_id': 'music-group-1',
          'artist': 'Porcupine Tree',
          'releases': [
            {
              'id': 'music-release-1',
              'release_group_id': 'music-group-1',
              'title': 'Kinesis CD',
              'publisher': 'Inside Out',
              'catalog_number': 'KDCD 1022',
              'mediums': <Map<String, dynamic>>[],
            },
          ],
        },
      ),
    );

    expect(group, isA<MusicReleaseGroup>());
    expect(group.id.value, 'music-group-1');
    expect(group.artist, 'Porcupine Tree');
    expect(group.releases, hasLength(1));
    expect(group.releases.first.catalogNumber, 'KDCD 1022');
    expect(group.releases.first.releaseGroupId, group.id);
  });
}
