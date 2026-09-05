import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/release/video_release_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('prefers catalog editions from core over local anchor synthesis', () {
    final catalogItem = typedCatalogItemFromMap({
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

    final editions = resolveVideoCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: [
        testOwnedItem(
          id: 'owned-1',
          itemId: 'movie-1',
          variantId: 'variant-local-only',
          updatedAt: DateTime.utc(2026, 5, 25),
        ),
      ],
    );

    expect(editions, hasLength(1));
    expect(editions.single.id, 'edition-core');
    expect(editions.single.title, 'Final Cut 4K release');
    expect(videoReleaseSourceLabel(editions.single), 'Catalog edition');
  });

  test('keeps local release synthesis when video item has no editions', () {
    final catalogItem = typedCatalogItemFromMap({
      'id': 'tmdb-local:movie:2',
      'kind': 'movie',
      'title': 'Dune',
      'physical_format_label': '4K UHD',
    });

    final editions = resolveVideoCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: [
        testOwnedItem(
          id: 'owned-2',
          itemId: 'movie-2',
          variantId: 'variant-4k',
          updatedAt: DateTime.utc(2026, 5, 25),
        ),
      ],
    );

    expect(editions, hasLength(1));
    expect(videoReleaseSourceLabel(editions.single), 'Collection anchors');
    expect(preferredVideoEditionVariantId(editions.single), 'variant-4k');
  });

  test('treats tv items as video library kinds for local release synthesis',
      () {
    final catalogItem = typedCatalogItemFromMap({
      'id': 'tmdb-local:tv:2',
      'kind': 'tv',
      'title': 'Severance',
      'physical_format_label': 'Blu-ray',
    });

    final editions = resolveVideoCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: [
        testOwnedItem(
          id: 'owned-tv-2',
          itemId: 'tv-2',
          variantId: 'variant-bluray',
          updatedAt: DateTime.utc(2026, 5, 25),
        ),
      ],
    );

    expect(editions, hasLength(1));
    expect(videoReleaseSourceLabel(editions.single), 'Collection anchors');
    expect(preferredVideoEditionVariantId(editions.single), 'variant-bluray');
  });

  test('does not synthesize title snapshot fallback for refreshed core items',
      () {
    final catalogItem = typedCatalogItemFromMap({
      'id': 'movie-3',
      'kind': 'movie',
      'title': 'Arrival',
    });

    final editions = resolveVideoCatalogEditionsForCatalogItem(catalogItem);

    expect(editions, isEmpty);
  });

  test('keeps title snapshot fallback for local synthetic video items', () {
    final catalogItem = typedCatalogItemFromMap({
      'id': 'tmdb-local:movie:4',
      'kind': 'movie',
      'title': 'Heat',
      'physical_format_label': 'Blu-ray',
      'release_date': DateTime.utc(1995, 12, 15).toIso8601String(),
    });

    final editions = resolveVideoCatalogEditionsForCatalogItem(catalogItem);

    expect(editions, hasLength(1));
    expect(videoReleaseSourceLabel(editions.single), 'Title snapshot fallback');
    expect(editions.single.title, 'Blu-ray');
  });

  test(
      'matchesVideoReleaseAnchor matches edition and synthetic variant anchors',
      () {
    const edition = CatalogEdition(
      id: 'edition-core',
      title: 'Collector Edition',
      metadata: {
        'release_anchor_kind': 'variant',
        'release_anchor_variant_id': 'variant-uhd',
      },
    );

    expect(
      matchesVideoReleaseAnchor(
        edition,
        editionId: 'edition-core',
      ),
      isTrue,
    );
    expect(
      matchesVideoReleaseAnchor(
        edition,
        variantId: 'variant-uhd',
      ),
      isTrue,
    );
    expect(
      matchesVideoReleaseAnchor(
        edition,
        variantId: 'variant-dvd',
      ),
      isFalse,
    );
  });
}
