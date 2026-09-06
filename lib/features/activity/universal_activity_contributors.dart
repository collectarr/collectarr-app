import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/activity/activity_event_contributor.dart';

/// Inputs for universal activity projections. The context contains only
/// models whose lifecycle semantics are shared across all kinds.
final class UniversalActivityContext {
  const UniversalActivityContext({
    this.ownedItems = const [],
    this.trackingEntries = const [],
    this.wishlistItems = const [],
    this.loans = const [],
  });

  final Iterable<OwnedItem> ownedItems;
  final Iterable<TrackingEntry> trackingEntries;
  final Iterable<WishlistItem> wishlistItems;
  final Iterable<Loan> loans;
}

final class OwnedActivityContributor
    implements ActivityEventContributor<UniversalActivityContext> {
  const OwnedActivityContributor();

  @override
  Iterable<ActivityEvent> contribute(UniversalActivityContext context) sync* {
    for (final item in context.ownedItems) {
      if (item.purchaseDate != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.purchased,
          timestamp: item.purchaseDate!,
          detail: item.purchaseStore,
          secondaryDetail: _priceLabel(item.pricePaidCents, item.currency),
        );
      }
      if (item.startedAt != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.started,
          timestamp: item.startedAt!,
        );
      }
      if (item.finishedAt != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.finished,
          timestamp: item.finishedAt!,
        );
      }
      if (item.soldAt != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.sold,
          timestamp: item.soldAt!,
          detail: item.soldTo,
          secondaryDetail: _priceLabel(item.sellPriceCents, item.currency),
        );
      }
      if (item.isDeleted && item.deletedAt != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.removedFromCollection,
          timestamp: item.deletedAt!,
        );
      }
      if (item.purchaseDate == null && !item.isDeleted) {
        yield ActivityEvent(
          kind: ActivityEventKind.addedToCollection,
          timestamp: item.updatedAt,
        );
      }
      if (item.rating != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.rated,
          timestamp: item.updatedAt,
          rating: item.rating,
        );
      }
    }
  }
}

final class TrackingActivityContributor
    implements ActivityEventContributor<UniversalActivityContext> {
  const TrackingActivityContributor();

  @override
  Iterable<ActivityEvent> contribute(UniversalActivityContext context) sync* {
    for (final entry in context.trackingEntries) {
      if (entry.isDeleted) continue;
      if (entry.startedAt != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.started,
          timestamp: entry.startedAt!,
        );
      }
      if (entry.finishedAt != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.finished,
          timestamp: entry.finishedAt!,
        );
      }
      if (entry.rating != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.rated,
          timestamp: entry.updatedAt,
          rating: entry.rating,
        );
      }
    }
  }
}

final class WishlistActivityContributor
    implements ActivityEventContributor<UniversalActivityContext> {
  const WishlistActivityContributor();

  @override
  Iterable<ActivityEvent> contribute(UniversalActivityContext context) sync* {
    for (final item in context.wishlistItems) {
      yield ActivityEvent(
        kind: ActivityEventKind.wishlisted,
        timestamp: item.createdAt,
      );
    }
  }
}

final class LoanActivityContributor
    implements ActivityEventContributor<UniversalActivityContext> {
  const LoanActivityContributor();

  @override
  Iterable<ActivityEvent> contribute(UniversalActivityContext context) sync* {
    for (final loan in context.loans) {
      yield ActivityEvent(
        kind: ActivityEventKind.loaned,
        timestamp: loan.lentDate,
        detail: loan.borrowerName,
      );
      if (loan.returnedDate != null) {
        yield ActivityEvent(
          kind: ActivityEventKind.loanReturned,
          timestamp: loan.returnedDate!,
          detail: loan.borrowerName,
        );
      }
    }
  }
}

const universalActivityContributors =
    <ActivityEventContributor<UniversalActivityContext>>[
  OwnedActivityContributor(),
  TrackingActivityContributor(),
  WishlistActivityContributor(),
  LoanActivityContributor(),
];

String? _priceLabel(int? cents, String? currency) {
  if (cents == null) return null;
  return '${(cents / 100).toStringAsFixed(2)} ${currency ?? ''}'.trim();
}
