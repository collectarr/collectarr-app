import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/stats/movie_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/value/movie_value_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_image_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('Movie provider mapper preserves typed fields and image fallback', () {
    const mapper = MovieLibraryKindProviderMapper();
    final envelope = _movieEnvelope(
      normalized: const {
        'title': 'Arrival',
        'runtime_minutes': 116,
        'genres': ['Drama', 'Sci-Fi'],
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
      images: const [
        ProviderImageRef(
          provider: 'tmdb',
          url: 'https://example.test/arrival.jpg',
        ),
      ],
    );

    final item = mapper.metadataItemFromEnvelope(envelope);
    final metadata = item.kindMetadata as MovieCatalogMetadata;
    final catalog = mapper.catalogFromEnvelope(envelope);

    expect(item.mediaKind, CatalogMediaKind.movie);
    expect(metadata.title, 'Arrival');
    expect(metadata.runtimeMinutes, 116);
    expect(metadata.directors.single.name, 'Denis Villeneuve');
    expect(metadata.releases.single.physicalFormat, '4k_uhd');
    expect(catalog.displayCoverUrl, 'https://example.test/arrival.jpg');
  });

  test('Movie provider mapper rejects a non-Movie envelope', () {
    const mapper = MovieLibraryKindProviderMapper();
    final envelope = _movieEnvelope(kind: 'tv');

    expect(() => mapper.metadataItemFromEnvelope(envelope), throwsStateError);
    expect(() => mapper.catalogFromEnvelope(envelope), throwsStateError);
  });

  test('Movie stats use typed metadata for runtime, ratings, and facets', () {
    final entries = [
      testShelfEntry(
        itemId: 'movie-1',
        kind: 'movie',
        catalogItem: testCatalogItem(
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
        ),
      ),
      testShelfEntry(
        itemId: 'movie-2',
        kind: 'movie',
        catalogItem: testCatalogItem(
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
        ),
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
      testShelfEntry(
        itemId: 'movie-1',
        kind: 'movie',
        ownedItem: testOwnedItem(
          itemId: 'movie-1',
          kind: 'movie',
          marketValueCents: 2400,
          currency: 'USD',
        ),
      ),
      testShelfEntry(
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

    final source = testShelfEntry(
      itemId: 'movie-provider-value',
      kind: 'movie',
      catalogItem: testCatalogItem(
        id: 'movie-provider-value',
        kind: 'movie',
        payload: const {'estimated_value_cents': 3200},
      ),
    );
    final projection = movieKindModule.project(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'movie-provider-value'),
    );

    expect(capability.resolveProviderValueCents(projection), 3200);
  });
}

NormalizedProviderEnvelopeV1 _movieEnvelope({
  String kind = 'movie',
  Map<String, dynamic> normalized = const <String, dynamic>{},
  List<ProviderImageRef> images = const <ProviderImageRef>[],
}) {
  return NormalizedProviderEnvelopeV1(
    provider: 'tmdb',
    providerItemId: 'movie-1',
    kind: kind,
    normalized: normalized,
    images: images,
    provenance: const ProviderProvenance(fetchedAt: '2026-01-01T00:00:00Z'),
    attribution: const ProviderAttribution(required: false),
  );
}
