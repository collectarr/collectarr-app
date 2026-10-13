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
        'revision': 1,
        'title': 'Kinesis',
        'artist': 'Ad Infinitum',
        'barcode': '1234567890',
        'catalog_number': 'KDCD 1022',
        'artist_credits': <Map<String, Object?>>[],
        'genres': <String>[],
        'extra': <String>[],
        'credits': <Map<String, Object?>>[],
        'external_links': <Map<String, Object?>>[],
        'discs': [
          {
            'id': 'd1',
            'disc_number': 1,
            'format': 'CD',
            'format_family': 'opticalDisc',
            'sound_types': <String>[],
            'recording_locations': <String>[],
            'credits': <Map<String, Object?>>[],
            'tracks': [
              {
                'id': 't1',
                'position': '1',
                'position_order': 1,
                'title': 'T1',
                'is_header': false,
                'parent_header_id': null,
                'indent_level': 0,
              },
              {
                'id': 't2',
                'position': '2',
                'position_order': 2,
                'title': 'T2',
                'is_header': false,
                'parent_header_id': null,
                'indent_level': 0,
              },
              {
                'id': 't3',
                'position': '3',
                'position_order': 3,
                'title': 'T3',
                'is_header': false,
                'parent_header_id': null,
                'indent_level': 0,
              },
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
