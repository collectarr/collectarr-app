import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final ownedItem = OwnedItem(
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
    final older = OwnedItem(
      id: 'owned-1',
      itemId: 'book-1',
      updatedAt: DateTime.utc(2026, 5, 24, 10),
    );
    final newer = OwnedItem(
      id: 'owned-2',
      itemId: 'book-1',
      updatedAt: DateTime.utc(2026, 5, 24, 11),
    );

    final resolution = resolveActiveOwnedItem(
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
}