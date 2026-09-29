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
        'title': 'Kinesis - Deluxe Edition',
        'physical_format_label': 'CD',
        'barcode': '1234567890',
        'series': {
          'series_title': 'Ad Infinitum',
          'volume_name': 'Deluxe Edition',
        },
        'music': {
          'track_count': 3,
          'catalog_number': 'KDCD 1022',
        },
      }).asSearchCandidate,
    );

    expect(display, isNotNull);
    expect(display!.title, 'Kinesis');
    expect(display.secondaryLine, 'Ad Infinitum');
    expect(display.detailLine,
        'Deluxe Edition - CD - 3 tracks - 1234567890 - KDCD 1022');
  });
}
