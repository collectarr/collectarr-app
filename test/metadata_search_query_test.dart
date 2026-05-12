import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds backend search query parameters', () {
    final query = MetadataSearchQuery(
      query: ' Spider-Man ',
      kind: 'comic',
      series: ' Amazing Spider-Man ',
      issueNumber: ' 13A ',
      publisher: ' Marvel ',
      year: 2016,
      barcode: '759606-083060-01412',
      limit: 50,
    );

    expect(query.isEmpty, isFalse);
    expect(query.toQueryParameters(), {
      'q': 'Spider-Man',
      'kind': 'comic',
      'series': 'Amazing Spider-Man',
      'issue_number': '13A',
      'publisher': 'Marvel',
      'year': 2016,
      'barcode': '75960608306001412',
      'limit': 50,
    });
  });

  test('detects empty metadata search', () {
    const query = MetadataSearchQuery(kind: 'comic', limit: 25);

    expect(query.isEmpty, isTrue);
    expect(query.toQueryParameters(), {'kind': 'comic', 'limit': 25});
  });
}
