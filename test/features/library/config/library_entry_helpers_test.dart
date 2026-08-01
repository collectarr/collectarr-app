import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('resolveActiveTrackingEntry prefers the tracking row for the active copy', () {
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
      anchorType: 'copy',
      ownedItemId: 'owned-1',
      progressCurrent: 50,
      updatedAt: DateTime.utc(2026, 5, 25, 11),
    );

    final resolved = resolveActiveTrackingEntry(
      activeOwnedItemId: 'owned-1',
      trackingEntries: [trackedOnly, copyTracked],
    );

    expect(resolved?.id, 'tracking-copy');
  });

  test('libraryReferenceHierarchySegments builds ordered hierarchy breadcrumbs', () {
    final hierarchy = libraryReferenceHierarchySegments(
      mediaType: 'music',
      editions: const [
        CatalogEdition(
          id: 'edition-1',
          name: 'Deluxe Edition',
          physicalFormat: 'Japan CD',
          physicalFormatLabel: 'Japan CD',
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

  test('libraryHierarchyContractDiagnosticLabel flags missing series title', () {
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'comic-5',
          kind: 'comic',
          title: 'Example Comic',
        ),
      ),
      node: const LibraryTitleNodeRef('comic-5'),
    );

    expect(
      libraryHierarchyContractDiagnosticLabel(item),
      'Missing series title',
    );
  });

  test('libraryHierarchyContractDiagnosticLabel flags missing release variant', () {
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'movie-2',
          kind: 'movie',
          title: 'Example Movie',
          series: CatalogSeriesDetails(seriesTitle: 'Example Movie'),
        ),
      ),
      node: const LibraryReleaseNodeRef('movie-2', releaseItemId: 'rel-2'),
    );

    expect(
      libraryHierarchyContractDiagnosticLabel(item),
      'Missing release variant',
    );
  });

  test('resolveLibraryMutationAnchor prefers explicit owned or wishlist release anchors', () {
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'movie-1',
          kind: 'movie',
          title: 'Spirited Away',
        ),
      ),
      node: const LibraryTitleNodeRef('movie-1'),
    );
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
