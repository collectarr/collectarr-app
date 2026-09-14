import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/release/movie_release_detail_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('prefers catalog editions from core over local anchor synthesis', () {
    final catalogItem = testCatalogItemFromJson({
      'id': 'movie-1',
      'kind': 'movie',
      'title': 'Blade Runner',
      'editions': [
        {
          'id': 'edition-core',
          'title': 'Final Cut 4K release',
          'release_date': DateTime.utc(1982, 6, 25).toIso8601String(),
          'variants': [
            {
              'id': 'variant-core',
              'name': '4K UHD',
              'is_primary': true,
            },
          ],
        },
      ],
    });

    final editions = resolveMovieCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: [
        _ownedSummary(
          id: 'owned-1',
          itemId: 'movie-1',
          variantId: 'variant-local-only',
        ),
      ],
    );

    expect(editions, hasLength(1));
    expect(editions.single.id, 'edition-core');
    expect(editions.single.title, 'Final Cut 4K release');
    expect(movieReleaseSourceLabel(editions.single), 'Catalog edition');
  });

  test('keeps local release synthesis when movie item has no editions', () {
    final catalogItem = testCatalogItemFromJson({
      'id': 'tmdb-local:movie:2',
      'kind': 'movie',
      'title': 'Dune',
      'physical_format_label': '4K UHD',
    });

    final editions = resolveMovieCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: [
        _ownedSummary(
          id: 'owned-2',
          itemId: 'movie-2',
          variantId: 'variant-4k',
        ),
      ],
    );

    expect(editions, hasLength(1));
    expect(movieReleaseSourceLabel(editions.single), 'Collection anchors');
    expect(preferredMovieEditionVariantId(editions.single), 'variant-4k');
  });

  test('treats tv items as movie library kinds for local release synthesis',
      () {
    final catalogItem = testCatalogItemFromJson({
      'id': 'tmdb-local:tv:2',
      'kind': 'tv',
      'title': 'Severance',
      'physical_format_label': 'Blu-ray',
    });

    final editions = resolveMovieCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: [
        _ownedSummary(
          id: 'owned-tv-2',
          itemId: 'tv-2',
          kind: CatalogMediaKind.tv,
          variantId: 'variant-bluray',
        ),
      ],
    );

    expect(editions, hasLength(1));
    expect(movieReleaseSourceLabel(editions.single), 'Collection anchors');
    expect(preferredMovieEditionVariantId(editions.single), 'variant-bluray');
  });

  test('does not synthesize title snapshot fallback for refreshed core items',
      () {
    final catalogItem = testCatalogItemFromJson({
      'id': 'movie-3',
      'kind': 'movie',
      'title': 'Arrival',
    });

    final editions = resolveMovieCatalogEditionsForCatalogItem(catalogItem);

    expect(editions, isEmpty);
  });

  test('keeps title snapshot fallback for local synthetic movie items', () {
    final catalogItem = testCatalogItemFromJson({
      'id': 'tmdb-local:movie:4',
      'kind': 'movie',
      'title': 'Heat',
      'physical_format_label': 'Blu-ray',
      'release_date': DateTime.utc(1995, 12, 15).toIso8601String(),
    });

    final editions = resolveMovieCatalogEditionsForCatalogItem(catalogItem);

    expect(editions, hasLength(1));
    expect(movieReleaseSourceLabel(editions.single), 'Title snapshot fallback');
    expect(editions.single.title, 'Blu-ray');
  });

  test(
      'matchesMovieReleaseAnchor matches edition and synthetic variant anchors',
      () {
    const edition = CatalogEditionDto(
      id: 'edition-core',
      title: 'Collector Edition',
      metadata: {
        'release_anchor_kind': 'variant',
        'release_anchor_variant_id': 'variant-uhd',
      },
    );

    expect(
      matchesMovieReleaseAnchor(
        edition,
        editionId: 'edition-core',
      ),
      isTrue,
    );
    expect(
      matchesMovieReleaseAnchor(
        edition,
        variantId: 'variant-uhd',
      ),
      isTrue,
    );
    expect(
      matchesMovieReleaseAnchor(
        edition,
        variantId: 'variant-dvd',
      ),
      isFalse,
    );
  });
}

OwnedItemSummary _ownedSummary({
  required String id,
  required String itemId,
  CatalogMediaKind kind = CatalogMediaKind.movie,
  String? variantId,
}) {
  return OwnedItemSummary(
    ref: OwnedItemRef(
      kind: kind,
      id: OwnedItemId(id),
    ),
    title: itemId,
    catalogRef: CatalogEntityRef(
      kind: kind,
      entityType: const CatalogEntityTypeId('owned_copy'),
      id: id,
      rootId: itemId,
    ),
    targetRef: variantId == null
        ? null
        : CatalogEntityRef(
            kind: kind,
            entityType: const CatalogEntityTypeId('release'),
            id: variantId,
            rootId: itemId,
          ),
  );
}
