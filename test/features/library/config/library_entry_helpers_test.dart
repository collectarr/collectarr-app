import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('resolveActiveTrackingEntry prefers the tracking row for the active copy', () {
    final trackedOnly = TrackingEntry(
      id: 'tracking-item',
      itemId: 'book-1',
      sourceType: 'physical',
      updatedAt: DateTime.utc(2026, 5, 24, 10),
    );
    final ownedTracking = TrackingEntry(
      id: 'tracking-owned-2',
      itemId: 'book-1',
      ownedItemId: 'owned-2',
      sourceType: 'physical',
      updatedAt: DateTime.utc(2026, 5, 24, 11),
    );
    final ownedItem = testOwnedItem(
      id: 'owned-2',
      itemId: 'book-1',
      updatedAt: DateTime.utc(2026, 5, 24, 11),
    );

    final resolved = resolveActiveTrackingEntry(
      [trackedOnly, ownedTracking],
      ownedItem,
    );

    expect(resolved?.id, 'tracking-owned-2');
  });

  test('resolveActiveOwnedItem picks the newest copy and requests selection sync', () {
    final older = testOwnedItem(
      id: 'owned-1',
      itemId: 'book-1',
      updatedAt: DateTime.utc(2026, 5, 24, 10),
    );
    final newer = testOwnedItem(
      id: 'owned-2',
      itemId: 'book-1',
      updatedAt: DateTime.utc(2026, 5, 24, 11),
    );

    final resolution = resolveActivetestOwnedItem(
      [newer, older],
      fallback: older,
      selectedOwnedItemId: null,
      selectNewest: true,
    );

    expect(resolution.ownedItem?.id, 'owned-2');
    expect(resolution.nextSelectedOwnedItemId, 'owned-2');
    expect(resolution.clearNewest, isTrue);
    expect(resolution.shouldScheduleSelection(null, true), isTrue);
  });

  test('libraryReferenceHierarchySegments resolves edition and physical release', () {
    final hierarchy = libraryReferenceHierarchySegments(
      mediaType: 'music',
      editions: const [
        CatalogEdition(
          id: 'edition-1',
          title: 'Deluxe Edition',
          variants: [
            CatalogVariant(
              id: 'variant-1',
              name: 'Japan CD',
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

  test('resolveLibraryMutationAnchor prefers explicit owned or wishlist release anchors', () {
    final entry = LibraryWorkspaceEntry(
      id: 'movie-1',
      mediaType: 'movie',
      title: 'Spirited Away',
      referenceEditionId: 'edition-title',
      updatedAt: DateTime.utc(2026, 5, 25),
    );
    final wishlistItem = WishlistItem(
      id: 'wishlist-1',
      itemId: 'movie-1',
      anchorType: 'variant',
      editionId: 'edition-4k',
      variantId: 'variant-uhd',
      createdAt: DateTime.utc(2026, 5, 25, 9),
      updatedAt: DateTime.utc(2026, 5, 25, 10),
    );

    final resolved = resolveLibraryMutationAnchor(
      entry: entry,
      wishlistItem: wishlistItem,
    );

    expect(resolved.anchorType, 'variant');
    expect(resolved.editionId, 'edition-4k');
    expect(resolved.variantId, 'variant-uhd');
    expect(resolved.bundleReleaseId, isNull);
  });
}
