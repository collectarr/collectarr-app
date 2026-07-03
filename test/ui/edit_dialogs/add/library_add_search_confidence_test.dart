import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exact core match suppresses provider fallback', () {
    final shouldFallback = shouldSearchProviderForCoreResults(
      [
        LibraryMetadataItem(
          id: 'comic-423',
          kind: 'comic',
          title: 'Batman',
          itemNumber: '423',
          publisher: 'DC',
          releaseYear: 1988,
          series: CatalogSeriesDetails(
            seriesTitle: 'Batman',
            volumeStartYear: 1988,
          ),
        ),
      ],
      const LibraryAddLocalRerankHints(
        query: 'Batman',
        series: 'Batman',
        issueNumber: '423',
        publisher: 'DC',
        year: 1988,
      ),
    );

    expect(shouldFallback, isFalse);
  });

  test('weak core top match keeps provider fallback enabled', () {
    final shouldFallback = shouldSearchProviderForCoreResults(
      [
        LibraryMetadataItem(
          id: 'movie-1',
          kind: 'movie',
          title: 'Blade Runner 2049',
          publisher: 'Warner Bros.',
          releaseYear: 2017,
        ),
      ],
      const LibraryAddLocalRerankHints(
        query: 'Blade Runner',
        series: '',
        issueNumber: '',
        publisher: '',
        year: null,
      ),
    );

    expect(shouldFallback, isTrue);
  });

  test('empty core results still trigger provider fallback', () {
    const hints = LibraryAddLocalRerankHints(
      query: 'Naruto',
      series: '',
      issueNumber: '',
      publisher: '',
      year: null,
    );

    expect(shouldSearchProviderForCoreResults(const [], hints), isTrue);
  });
}
