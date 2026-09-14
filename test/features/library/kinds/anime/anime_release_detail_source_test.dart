import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/release/anime_release_detail_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('prefers catalog editions from core over local anchor synthesis', () {
    final catalogItem =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'anime-1',
      'kind': 'anime',
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
    })).toImportSnapshot();

    final editions = resolveAnimeCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: [
        _ownedSummary(
          id: 'owned-1',
          itemId: 'anime-1',
          variantId: 'variant-local-only',
        ),
      ],
    );

    expect(editions, hasLength(1));
    expect(editions.single.id, 'edition-core');
    expect(editions.single.title, 'Final Cut 4K release');
    expect(animeReleaseSourceLabel(editions.single), 'Catalog edition');
  });

  test('keeps local release synthesis when anime item has no editions', () {
    final catalogItem =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tmdb-local:anime:2',
      'kind': 'anime',
      'title': 'Dune',
      'physical_format_label': '4K UHD',
    })).toImportSnapshot();

    final editions = resolveAnimeCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: [
        _ownedSummary(
          id: 'owned-2',
          itemId: 'anime-2',
          variantId: 'variant-4k',
        ),
      ],
    );

    expect(editions, hasLength(1));
    expect(animeReleaseSourceLabel(editions.single), 'Collection anchors');
    expect(preferredAnimeEditionVariantId(editions.single), 'variant-4k');
  });

  test('treats tv items as anime library kinds for local release synthesis',
      () {
    final catalogItem =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tmdb-local:tv:2',
      'kind': 'tv',
      'title': 'Severance',
      'physical_format_label': 'Blu-ray',
    })).toImportSnapshot();

    final editions = resolveAnimeCatalogEditionsForCatalogItem(
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
    expect(animeReleaseSourceLabel(editions.single), 'Collection anchors');
    expect(preferredAnimeEditionVariantId(editions.single), 'variant-bluray');
  });

  test('does not synthesize title snapshot fallback for refreshed core items',
      () {
    final catalogItem =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'anime-3',
      'kind': 'anime',
      'title': 'Arrival',
    })).toImportSnapshot();

    final editions = resolveAnimeCatalogEditionsForCatalogItem(catalogItem);

    expect(editions, isEmpty);
  });

  test('keeps title snapshot fallback for local synthetic anime items', () {
    final catalogItem =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tmdb-local:anime:4',
      'kind': 'anime',
      'title': 'Heat',
      'physical_format_label': 'Blu-ray',
      'release_date': DateTime.utc(1995, 12, 15).toIso8601String(),
    })).toImportSnapshot();

    final editions = resolveAnimeCatalogEditionsForCatalogItem(catalogItem);

    expect(editions, hasLength(1));
    expect(animeReleaseSourceLabel(editions.single), 'Title snapshot fallback');
    expect(editions.single.title, 'Blu-ray');
  });

  test(
      'matchesAnimeReleaseAnchor matches edition and synthetic variant anchors',
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
      matchesAnimeReleaseAnchor(
        edition,
        editionId: 'edition-core',
      ),
      isTrue,
    );
    expect(
      matchesAnimeReleaseAnchor(
        edition,
        variantId: 'variant-uhd',
      ),
      isTrue,
    );
    expect(
      matchesAnimeReleaseAnchor(
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
  CatalogMediaKind kind = CatalogMediaKind.anime,
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
