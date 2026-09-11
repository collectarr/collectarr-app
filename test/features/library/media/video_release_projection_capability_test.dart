import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/release/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoReleaseProjectionCapability', () {
    const capability = VideoReleaseProjectionCapability<LibraryWorkspaceDto>();
    final typeConfig = libraryKindModuleForKind(CatalogMediaKind.movie);

    test('no edition returns empty list', () {
      final catalogItem = testCatalogItem(
        id: 'movie_1',
        kind: 'movie',
        title: 'Empty Movie',
      );
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1', catalogTransport: catalogItem.asShelfCatalogItem);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
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
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1', catalogTransport: catalogItem.asShelfCatalogItem);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
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
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1', catalogTransport: catalogItem.asShelfCatalogItem);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
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
      final owned = _movieOwnedSummary(
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: const CatalogEntityTypeId('edition'),
          id: 'ed_1',
          rootId: 'movie_1',
        ),
      );
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1',
          catalogTransport: catalogItem.asShelfCatalogItem,
          ownedSummary: owned);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
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
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: const CatalogEntityTypeId('edition'),
          id: 'ed_1',
          rootId: 'movie_1',
        ),
      );
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1',
          catalogTransport: catalogItem.asShelfCatalogItem,
          wishlistItem: wishlist);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
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
      final owned = _movieOwnedSummary(
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: const CatalogEntityTypeId('release'),
          id: 'var_b',
          rootId: 'movie_1',
        ),
      );
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1',
          catalogTransport: catalogItem.asShelfCatalogItem,
          ownedSummary: owned);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
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
      final owned = _movieOwnedSummary(
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: const CatalogEntityTypeId('bundle_release'),
          id: 'ed_1',
          rootId: 'movie_1',
        ),
      );
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1',
          catalogTransport: catalogItem.asShelfCatalogItem,
          ownedSummary: owned);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
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
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1', catalogTransport: catalogItem.asShelfCatalogItem);

      final items = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
      );

      expect(items.length, 1);
      final dto = items.first.dto;
      final movieDto = dto is MovieWorkspaceDto ? dto : null;
      expect(movieDto?.barcode, '987654321');
      expect(dto.coverImageUrl, 'https://img.com/cover.jpg');
      expect(movieDto?.releaseDate, DateTime(2022, 11, 15));
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
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1', catalogTransport: catalogItem.asShelfCatalogItem);
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
      final source = LibraryWorkspaceSource(
          itemId: 'movie_1', catalogTransport: catalogItem.asShelfCatalogItem);

      final match = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
        requestedTitleId: 'movie_1',
      );
      expect(match.length, 1);

      final mismatch = capability.projectReleases(
        source: source,
        type: typeConfig,
        projector: libraryKindWorkspaceForKind(typeConfig.kind).projector,
        customFieldDefinitions: const [],
        customFieldValuesByDefinitionByItem: const {},
        customFieldValuesByItem: const {},
        requestedTitleId: 'movie_other',
      );
      expect(mismatch, isEmpty);
    });

    test('unsupported scope fails explicitly for non-release kinds', () {
      final comicConfig = libraryKindModuleForKind(CatalogMediaKind.comic);
      expect(comicConfig.releaseCapability, isNull);

      final shelf = ShelfState(
        entries: const [],
        workspaceEntries: [
          LibraryWorkspaceSource(
            itemId: 'comic_1',
            catalogTransport: testCatalogItem(
              id: 'comic_1',
              kind: 'comic',
              title: 'Spider-Man #1',
            ).asShelfCatalogItem,
          ),
        ],
        ownedCount: 0,
        wishlistCount: 0,
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

OwnedItemSummary _movieOwnedSummary({required CatalogEntityRef targetRef}) {
  return OwnedItemSummary(
    ref: const OwnedItemRef(
      kind: CatalogMediaKind.movie,
      id: OwnedItemId('owned-1'),
    ),
    title: 'movie_1',
    catalogRef: const CatalogEntityRef(
      kind: CatalogMediaKind.movie,
      entityType: CatalogEntityTypeId('owned_copy'),
      id: 'owned-1',
      rootId: 'movie_1',
    ),
    targetRef: targetRef,
  );
}
