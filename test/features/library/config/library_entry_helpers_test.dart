import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'resolveActiveTrackingEntry prefers the tracking row for the active copy',
      () {
    final trackedOnly = TrackingEntry(
      id: 'tracking-item',
      catalogRef: const CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-1',
      ),
      progressCurrent: 10,
      updatedAt: DateTime.utc(2026, 5, 25, 10),
    );
    final copyTracked = TrackingEntry(
      id: 'tracking-copy',
      catalogRef: const CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-1',
      ),
      ownedItemId: 'owned-1',
      progressCurrent: 50,
      updatedAt: DateTime.utc(2026, 5, 25, 11),
    );

    final resolved = resolveActiveTrackingEntry(
      [trackedOnly, copyTracked],
      OwnedItem(
        id: 'owned-1',
        catalogRef: const CatalogEntityRef(
          kind: 'book',
          entityType: CatalogEntityType.work,
          id: 'book-1',
        ),
        updatedAt: DateTime.utc(2026, 5, 25, 11),
      ),
    );

    expect(resolved?.id, 'tracking-copy');
  });

  test('libraryReferenceHierarchySegments builds ordered hierarchy breadcrumbs',
      () {
    final hierarchy = libraryReferenceHierarchySegments(
      mediaType: 'music',
      editions: const [
        CatalogEdition(
          id: 'edition-1',
          title: 'Deluxe Edition',
          physicalFormat: 'Japan CD',
          physicalFormatLabel: 'Japan CD',
          variants: [
            CatalogVariant(
              id: 'variant-1',
              name: 'Japan CD',
              physicalFormatLabel: 'Japan CD',
            ),
          ],
        ),
      ],
      editionId: 'edition-1',
      variantId: 'variant-1',
    );

    expect(
      hierarchy,
      ['Album', 'Edition: Deluxe Edition', 'Physical: Japan CD'],
    );
  });

  test('libraryHierarchyContractDiagnosticLabel flags missing series title',
      () {
    final source = ShelfEntry(
      itemId: 'comic-5',
      catalogItem: testCatalogItem(
        id: 'comic-5',
        kind: 'comic',
        title: 'Example Comic',
      ),
    );
    final node = LibraryTitleNodeRef(titleItemId: 'comic-5');
    final dto = const GenericWorkspaceProjector()
        .projectTitle(source: source, node: node);
    final item = LibraryProjectionItem(source: source, node: node, dto: dto);

    expect(
      libraryHierarchyContractDiagnosticLabel(item),
      'Missing series title',
    );
  });

  test('libraryHierarchyContractDiagnosticLabel flags missing release variant',
      () {
    final edition = CatalogEdition(id: 'rel-2', title: '');
    final source = ShelfEntry(
      itemId: 'movie-2',
      catalogItem: testCatalogItem(
        id: 'movie-2',
        kind: 'movie',
        title: 'Example Movie',
        series: CatalogSeriesDetailsDto(seriesTitle: 'Example Movie'),
      ),
    );
    final node = LibraryReleaseNodeRef(
      titleItemId: 'movie-2',
      releaseId: 'rel-2',
      edition: edition,
    );
    final dto = const GenericWorkspaceProjector().projectRelease(
      source: source,
      node: node,
      releaseState: const LibraryReleaseState(
        isOwned: false,
        isWishlisted: false,
        isTracked: false,
        referenceEditionId: 'rel-2',
      ),
    );
    final item = LibraryProjectionItem(source: source, node: node, dto: dto);

    expect(
      libraryHierarchyContractDiagnosticLabel(item),
      'Missing release variant',
    );
  });

  test(
      'resolveLibraryMutationAnchor prefers explicit owned or wishlist release anchors',
      () {
    final source = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Spirited Away',
      ),
    );
    final node = LibraryTitleNodeRef(titleItemId: 'movie-1');
    final dto = const GenericWorkspaceProjector()
        .projectTitle(source: source, node: node);
    final item = LibraryProjectionItem(source: source, node: node, dto: dto);

    final wishlistItem = WishlistItem(
      id: 'wishlist-1',
      catalogRef: const CatalogEntityRef(
        kind: 'movie',
        entityType: CatalogEntityType.work,
        id: 'movie-1',
      ),
      anchorType: 'variant',
      editionId: 'edition-4k',
      variantId: 'variant-uhd',
      createdAt: DateTime.utc(2026, 5, 25, 9),
      updatedAt: DateTime.utc(2026, 5, 25, 10),
    );

    final resolved = resolveLibraryMutationAnchor(
      item: item,
      wishlistItem: wishlistItem,
    );

    expect(resolved.anchorType, 'variant');
    expect(resolved.editionId, 'edition-4k');
    expect(resolved.variantId, 'variant-uhd');
    expect(resolved.bundleReleaseId, isNull);
  });
}
