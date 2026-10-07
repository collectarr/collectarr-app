import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music search result display formats album metadata', () {
    const builder = MusicLibraryMediaPresentationBuilder();
    final display = builder.buildSearchResultDisplay(
      item: testCatalogItemFromJson({
        'id': 'music-search-1',
        'kind': 'music',
        'title': 'Kinesis',
        'artist': 'Ad Infinitum',
        'format': 'CD',
        'barcode': '1234567890',
        'catalog_number': 'KDCD 1022',
        'discs': [
          {
            'id': 'd1',
            'disc_number': 1,
            'tracks': [
              {'id': 't1', 'title': 'T1'},
              {'id': 't2', 'title': 'T2'},
              {'id': 't3', 'title': 'T3'},
            ],
          }
        ],
      }).asSearchCandidate,
    );

    expect(display, isNotNull);
    expect(display!.title, 'Kinesis');
    expect(display.secondaryLine, 'Ad Infinitum');
    expect(display.detailLine, 'CD - 3 tracks - 1234567890 - KDCD 1022');
  });
}
