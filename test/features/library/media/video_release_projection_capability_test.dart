import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoReleaseProjectionCapability', () {
    const capability = VideoReleaseProjectionCapability<LibraryWorkspaceDto>();
    final typeConfig = libraryKindRuntimeForKind(CatalogMediaKind.movie).type;

    test('no edition returns empty list', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Empty Movie',
      );
      final source = ShelfEntry(itemId: 'movie_1', catalogItem: catalogItem);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items, isEmpty);
    });

    test('single edition projects single release item', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Single Edition Movie',
        editions: [
          CatalogEditionDto(
            id: 'ed_1',
            title: 'Collector Edition',
            upc: '123456789',
            releaseDate: DateTime(2023, 5, 1),
            variants: const [
              CatalogVariantDto(
                id: 'var_1',
                name: '4K Steelbook',
                coverImageUrl: 'https://img.com/var1.jpg',
              ),
            ],
          ),
        ],
      );
      final source = ShelfEntry(itemId: 'movie_1', catalogItem: catalogItem);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items.length, 1);
      expect(items.first.node, isA<LibraryReleaseNodeRef>());
      final releaseNode = items.first.node as LibraryReleaseNodeRef;
      expect(releaseNode.releaseId, 'ed_1');
      expect(items.first.dto.title, 'Single Edition Movie');
    });

    test('multiple editions project multiple release items', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Multi Edition Movie',
        editions: const [
          CatalogEditionDto(id: 'ed_1', title: 'Standard DVD'),
          CatalogEditionDto(id: 'ed_2', title: '4K Blu-ray'),
        ],
      );
      final source = ShelfEntry(itemId: 'movie_1', catalogItem: catalogItem);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items.length, 2);
      final releaseIds = items
          .map((i) => (i.node as LibraryReleaseNodeRef).releaseId)
          .toList();
      expect(releaseIds, ['ed_1', 'ed_2']);
    });

    test('owned release sets isOwned flag on projected release', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Owned Release Movie',
        editions: const [
          CatalogEditionDto(id: 'ed_1', title: 'Special Edition'),
        ],
      );
      final owned = OwnedItem(
        id: 'own_1',
        updatedAt: DateTime(2026),
        editionId: 'ed_1',
        catalogRef: const CatalogEntityRef(
          kind: 'movie',
          entityType: CatalogEntityType.ownedCopy,
          id: 'movie_1',
        ),
      );
      final source = ShelfEntry(
          itemId: 'movie_1', catalogItem: catalogItem, ownedItem: owned);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items.length, 1);
      expect(items.first.source.isOwned, isTrue);
    });

    test('wishlist release sets isWishlisted flag on projected release', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Wishlisted Release Movie',
        editions: const [
          CatalogEditionDto(id: 'ed_1', title: 'Collector Edition'),
        ],
      );
      final wishlist = WishlistItem(
        id: 'wish_1',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        editionId: 'ed_1',
        catalogRef: const CatalogEntityRef(
          kind: 'movie',
          entityType: CatalogEntityType.edition,
          id: 'movie_1',
        ),
      );
      final source = ShelfEntry(
          itemId: 'movie_1', catalogItem: catalogItem, wishlistItem: wishlist);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items.length, 1);
      expect(items.first.source.isWishlisted, isTrue);
    });

    test('variant match links owned item variant correctly', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Variant Movie',
        editions: const [
          CatalogEditionDto(
            id: 'ed_1',
            title: 'Steelbook Edition',
            variants: [
              CatalogVariantDto(id: 'var_a', name: 'Cover A'),
              CatalogVariantDto(id: 'var_b', name: 'Cover B'),
            ],
          ),
        ],
      );
      final owned = OwnedItem(
        id: 'own_1',
        updatedAt: DateTime(2026),
        editionId: 'ed_1',
        variantId: 'var_b',
        catalogRef: const CatalogEntityRef(
          kind: 'movie',
          entityType: CatalogEntityType.ownedCopy,
          id: 'movie_1',
        ),
      );
      final source = ShelfEntry(
          itemId: 'movie_1', catalogItem: catalogItem, ownedItem: owned);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items.length, 1);
      expect(items.first.source.isOwned, isTrue);
    });

    test('bundle match links owned bundle release', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Bundle Movie',
        editions: const [
          CatalogEditionDto(id: 'ed_1', title: 'Trilogy Pack'),
        ],
      );
      final owned = OwnedItem(
        id: 'own_1',
        updatedAt: DateTime(2026),
        bundleReleaseId: 'ed_1',
        catalogRef: const CatalogEntityRef(
          kind: 'movie',
          entityType: CatalogEntityType.ownedCopy,
          id: 'movie_1',
        ),
      );
      final source = ShelfEntry(
          itemId: 'movie_1', catalogItem: catalogItem, ownedItem: owned);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items.length, 1);
      expect(items.first.source.isOwned, isTrue);
    });

    test('release cover, release date, and release barcode projected cleanly',
        () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Detailed Movie',
        editions: [
          CatalogEditionDto(
            id: 'ed_1',
            title: 'Remastered',
            upc: '987654321',
            releaseDate: DateTime(2022, 11, 15),
            variants: const [
              CatalogVariantDto(
                id: 'var_1',
                name: 'Cover 1',
                coverImageUrl: 'https://img.com/cover.jpg',
              ),
            ],
          ),
        ],
      );
      final source = ShelfEntry(itemId: 'movie_1', catalogItem: catalogItem);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items.length, 1);
      final dto = items.first.dto;
      final adapter = dto is WorkspaceDtoAdapter ? dto : null;
      expect(adapter?.barcode, '987654321');
      expect(dto.coverImageUrl, 'https://img.com/cover.jpg');
      expect(adapter?.releaseDate, DateTime(2022, 11, 15));
    });

    test('custom field target IDs include release ID', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Custom Field Movie',
        editions: const [
          CatalogEditionDto(id: 'ed_cf', title: 'CF Edition'),
        ],
      );
      final source = ShelfEntry(itemId: 'movie_1', catalogItem: catalogItem);
      final releaseNode = const LibraryReleaseNodeRef(
        titleItemId: 'movie_1',
        releaseId: 'ed_cf',
        edition: CatalogEditionDto(id: 'ed_cf', title: 'CF Edition'),
      );

      final targetIds = customFieldTargetIds(source: source, node: releaseNode);
      expect(targetIds, contains('ed_cf'));
      expect(targetIds, contains('movie_1'));
    });

    test('requestedTitleId filters out unrelated titles (navigation)', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Nav Movie',
        editions: const [
          CatalogEditionDto(id: 'ed_1', title: 'Nav Edition'),
        ],
      );
      final source = ShelfEntry(itemId: 'movie_1', catalogItem: catalogItem);

      final match = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
        requestedTitleId: 'movie_1',
      );
      expect(match.length, 1);

      final mismatch = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: typeConfig.presentation.projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
        requestedTitleId: 'movie_other',
      );
      expect(mismatch, isEmpty);
    });

    test('unsupported scope fails explicitly for non-release kinds', () {
      final comicConfig =
          libraryKindRuntimeForKind(CatalogMediaKind.comic).type;
      expect(comicConfig.releaseCapability, isNull);

      final shelf = ShelfState(
        entries: [
          ShelfEntry(
            itemId: 'comic_1',
            catalogItem: testCatalogItem(
              id: 'comic_1',
              kind: 'comic',
              title: 'Spider-Man #1',
            ),
          ),
        ],
        ownedCount: 0,
        wishlistCount: 0,
        missingGradeCount: 0,
        pricedCount: 0,
        totalPaidCents: 0,
        primaryCurrency: 'USD',
        hasMixedCurrencies: false,
      );

      expect(
        () => libraryItemsForShelf(
          shelf,
          comicConfig,
          browserMode: LibraryWorkspaceBrowserMode.releases,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
