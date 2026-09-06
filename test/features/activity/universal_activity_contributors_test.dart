import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/activity/universal_activity_contributors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects universal lifecycle domains without kind semantics', () {
    final catalogRef = const CatalogEntityRef(
      kind: 'book',
      entityType: CatalogEntityType.work,
      id: 'book-activity',
    );
    final now = DateTime.utc(2026, 9, 1);
    final owned = OwnedItem(
      id: 'owned-book-activity',
      catalogRef: catalogRef,
      purchaseDate: now,
      startedAt: now.add(const Duration(days: 1)),
      finishedAt: now.add(const Duration(days: 2)),
      soldAt: now.add(const Duration(days: 3)),
      soldTo: 'Collector',
      updatedAt: now,
    );
    final tracking = TrackingEntry(
      id: 'tracking-book-activity',
      catalogRef: catalogRef,
      status: MediaTrackingStatus.completed,
      rating: 9,
      startedAt: now.add(const Duration(days: 4)),
      updatedAt: now.add(const Duration(days: 4)),
    );
    final wishlist = WishlistItem(
      id: 'wishlist-book-activity',
      catalogRef: catalogRef,
      createdAt: now.add(const Duration(days: 5)),
      updatedAt: now.add(const Duration(days: 5)),
    );
    final loan = Loan(
      id: 'loan-book-activity',
      ownedRef: OwnedItemRef(
        kind: catalogRef.mediaKind,
        id: owned.typedId,
      ),
      borrowerName: 'Reader',
      lentDate: now.add(const Duration(days: 6)),
      returnedDate: now.add(const Duration(days: 7)),
    );

    final events = universalActivityContributors
        .expand(
          (contributor) => contributor.contribute(
            UniversalActivityContext(
              ownedItems: [owned],
              trackingEntries: [tracking],
              wishlistItems: [wishlist],
              loans: [loan],
            ),
          ),
        )
        .toList();

    expect(
        events.map((event) => event.kind),
        containsAll([
          ActivityEventKind.purchased,
          ActivityEventKind.started,
          ActivityEventKind.finished,
          ActivityEventKind.sold,
          ActivityEventKind.rated,
          ActivityEventKind.wishlisted,
          ActivityEventKind.loaned,
          ActivityEventKind.loanReturned,
        ]));
    expect(
        events
            .singleWhere((event) => event.kind == ActivityEventKind.sold)
            .detail,
        'Collector');
    expect(
      events
          .singleWhere((event) => event.kind == ActivityEventKind.loaned)
          .detail,
      'Reader',
    );
  });
}
