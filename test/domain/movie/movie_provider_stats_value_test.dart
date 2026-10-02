import 'package:collectarr_app/features/library/kinds/movie/stats/movie_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/value/movie_value_capability.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('Movie stats use typed metadata for runtime, ratings, and facets', () {
    final entries = [
      testLibraryWorkspaceSource(
        itemId: 'movie-1',
        kind: 'movie',
        catalogData: testWorkspaceCatalogData(testCatalogItem(
          id: 'movie-1',
          kind: 'movie',
          title: 'Arrival',
          payload: const {
            'runtime_minutes': 116,
            'audience_rating': '8.0',
            'genres': ['Drama', 'Sci-Fi'],
            'directors': [
              {'name': 'Denis Villeneuve'},
            ],
            'physical_format': 'blu-ray',
          },
        )),
      ),
      testLibraryWorkspaceSource(
        itemId: 'movie-2',
        kind: 'movie',
        catalogData: testWorkspaceCatalogData(testCatalogItem(
          id: 'movie-2',
          kind: 'movie',
          title: 'Dune',
          payload: const {
            'runtime_minutes': 155,
            'audience_rating': '8.5',
            'genres': ['Drama', 'Sci-Fi'],
            'directors': [
              {'name': 'Denis Villeneuve'},
            ],
            'physical_format_label': '4K UHD',
          },
        )),
      ),
    ];

    expect(MovieStatsCapability.totalRuntimeMinutes(entries), 271);
    expect(MovieStatsCapability.averageAudienceRating(entries), 8.25);
    expect(
        MovieStatsCapability.countGenres(entries), {'Drama': 2, 'Sci-Fi': 2});
    expect(MovieStatsCapability.countDirectors(entries), {
      'Denis Villeneuve': 2,
    });
    expect(MovieStatsCapability.countFormats(entries), {
      'blu-ray': 1,
      '4K UHD': 1,
    });
    expect(MovieStatsCapability.formatRuntime(271), '4h 31m');
  });

  test('Movie value capability summarizes owned market values', () {
    final entries = [
      testLibraryWorkspaceSource(
        itemId: 'movie-1',
        kind: 'movie',
        collectionItem: testCollectionItem(
          itemId: 'movie-1',
          kind: 'movie',
          marketValueCents: 2400,
          currency: 'USD',
        ),
      ),
      testLibraryWorkspaceSource(
        itemId: 'movie-2',
        kind: 'movie',
        collectionItem: testCollectionItem(
          itemId: 'movie-2',
          kind: 'movie',
          marketValueCents: 1600,
          currency: 'USD',
        ),
      ),
    ];
    const capability = MovieValueCapability();
    final summary = capability.resolveCollectionValueSummary(entries);

    expect(summary?.valuedCount, 2);
    expect(summary?.totalValueCents, 4000);
    expect(summary?.currency, 'USD');
    expect(summary?.hasMixedCurrencies, isFalse);
  });
}
