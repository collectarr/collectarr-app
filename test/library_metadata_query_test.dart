import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library metadata query uses the library kind', () {
    final query = libraryMetadataSearchQuery(
      comicsLibraryConfig,
      query: 'Spider-Man',
      issueNumber: '1',
      barcode: '7596-060',
      limit: 10,
    );

    expect(query.kind, 'comic');
    expect(query.toQueryParameters(), {
      'q': 'Spider-Man',
      'kind': 'comic',
      'issue_number': '1',
      'barcode': '7596060',
      'limit': 10,
    });
  });
}
