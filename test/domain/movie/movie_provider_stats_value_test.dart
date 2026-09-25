import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_provider_candidate_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/stats/movie_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/value/movie_value_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('Movie Add projection decodes Core catalog payload into typed metadata',
      () {
    final providerCandidate = CatalogSearchCandidate.fromItem(
      CatalogItemDto.raw(
        id: 'movie-1',
        mediaKind: CatalogMediaKind.movie,
        common: const CatalogCommonDto(
          title: 'Arrival',
          coverImageUrl: 'https://example.test/arrival.jpg',
        ),
        payload: const {
          'runtime_minutes': 116,
          'directors': [
            {'name': 'Denis Villeneuve', 'role': 'Director'},
          ],
          'releases': [
            {
              'id': 'release-1',
              'title': '4K UHD',
              'physical_format': '4k_uhd',
            },
          ],
        },
      ),
    );

    final candidate = movieCatalogTransportFromCoreItem(providerCandidate);
    final metadata = candidate.kindCapability
        .mapTransport((transport) => transport.kindMetadata);

    expect(metadata, isA<MovieCatalogMetadata>());
    final movie = metadata as MovieCatalogMetadata;
    expect(movie.title, 'Arrival');
    expect(movie.runtimeMinutes, 116);
    expect(movie.directors.single.name, 'Denis Villeneuve');
    expect(movie.releases.single.physicalFormat, '4k_uhd');
    expect(candidate.summary.imageUrl, 'https://example.test/arrival.jpg');
  });

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

  test('Movie value capability summarizes market values and provider values',
      () {
    final entries = [
      testLibraryWorkspaceSource(
        itemId: 'movie-1',
        kind: 'movie',
        ownedItem: testOwnedItem(
          itemId: 'movie-1',
          kind: 'movie',
          marketValueCents: 2400,
          currency: 'USD',
        ),
      ),
      testLibraryWorkspaceSource(
        itemId: 'movie-2',
        kind: 'movie',
        ownedItem: testOwnedItem(
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

    final source = testLibraryWorkspaceSource(
      itemId: 'movie-provider-value',
      kind: 'movie',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'movie-provider-value',
        kind: 'movie',
        payload: const {'estimated_value_cents': 3200},
      )),
    );
    final projection =
        libraryKindWorkspaceForKind(CatalogMediaKind.movie).project(
      source: source,
      node: const LibraryWorkRef(workId: 'movie-provider-value'),
    );

    expect(capability.resolveProviderValueCents(projection), 3200);
  });
}
