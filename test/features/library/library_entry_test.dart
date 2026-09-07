import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library entry exposes only structural ownership and tracking state',
      () {
    final entry = LibraryEntry(
      itemId: 'comic-1',
      catalogSummary: CatalogDisplaySummary.work(
        kind: CatalogMediaKind.comic,
        id: 'comic-1',
        title: 'Saga #1',
      ),
      ownedSummary: OwnedItemSummary(
        ref: OwnedItemRef(
          kind: CatalogMediaKind.comic,
          id: OwnedItemId('owned-1'),
        ),
        title: 'Saga #1',
        catalogRef: const CatalogEntityRef(
          kind: 'comic',
          entityType: CatalogEntityType.work,
          id: 'comic-1',
        ),
        updatedAt: DateTime.utc(2026, 5, 12),
      ),
      trackingSummary: TrackingSummary(
        catalogRef: const CatalogEntityRef(
          kind: 'comic',
          entityType: CatalogEntityType.work,
          id: 'comic-1',
        ),
        tracking: const MediaTracking(status: MediaTrackingStatus.inProgress),
        updatedAt: DateTime.utc(2026, 5, 12),
      ),
    );

    expect(entry.title, 'Saga #1');
    expect(entry.subtitle, 'Owned');
    expect(entry.isOwned, isTrue);
    expect(entry.isWishlisted, isFalse);
    expect(entry.tracking.status, MediaTrackingStatus.inProgress);
  });

  test('library entry falls back when catalog metadata is missing', () {
    const entry = LibraryEntry(itemId: 'abcdef123456');

    expect(entry.title, 'Catalog item abcdef12');
    expect(entry.subtitle, 'Wishlist');
    expect(entry.tracking.status, MediaTrackingStatus.none);
  });
}
