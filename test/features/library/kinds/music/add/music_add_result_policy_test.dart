import 'package:collectarr_app/features/library/kinds/music/add/music_add_result_policy.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music Core results group by album title and artist', () {
    final candidate = testCatalogItem(
      kind: 'music',
      title: 'Transport title',
      music: {
        'title': 'Kind of Blue',
        'artist': 'Miles Davis',
      },
    ).asSearchCandidate;

    expect(musicAddResultPolicy.coreGroupTitle(candidate), 'Kind of Blue');
    expect(musicAddResultPolicy.coreGroupArtist(candidate), 'Miles Davis');
  });
}
