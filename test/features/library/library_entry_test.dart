import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
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
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('work'),
          id: 'comic-1',
        ),
        updatedAt: DateTime.utc(2026, 5, 12),
      ),
      trackingSummary: TrackingSummary(
        id: 'tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('work'),
          id: 'comic-1',
        ),
        status: MediaTrackingStatus.inProgress,
        updatedAt: DateTime.utc(2026, 5, 12),
      ),
    );

    expect(entry.title, 'Saga #1');
    expect(entry.subtitle, 'Owned');
    expect(entry.isOwned, isTrue);
    expect(entry.isWishlisted, isFalse);
    expect(entry.trackingStatus, MediaTrackingStatus.inProgress);
  });

  test('library entry falls back when catalog metadata is missing', () {
    const entry = LibraryEntry(itemId: 'abcdef123456');

    expect(entry.title, 'Catalog item abcdef12');
    expect(entry.subtitle, 'Wishlist');
    expect(entry.trackingStatus, MediaTrackingStatus.none);
  });
}
