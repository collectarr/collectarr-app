import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';

/// Aggregates [ActivityEvent]s for a single catalog item from the various
/// domain models that carry date information.
class ActivityEventAggregator {
  const ActivityEventAggregator._();

  /// Build a time-sorted (newest-first) list of activity events for one item.
  static List<ActivityEvent> aggregate({
    required List<OwnedItem> ownedItems,
    required List<TrackingEntry> trackingEntries,
    required List<WatchSession> watchSessions,
    required List<WishlistItem> wishlistItems,
    required List<Loan> loans,
  }) {
    final events = <ActivityEvent>[];

    // --- Owned item events ---
    for (final item in ownedItems) {
      // Purchase
      if (item.purchaseDate != null) {
        final priceStr = item.pricePaidCents != null
            ? '${(item.pricePaidCents! / 100).toStringAsFixed(2)} ${item.currency ?? ''}'.trim()
            : null;
        events.add(ActivityEvent(
          kind: ActivityEventKind.purchased,
          timestamp: item.purchaseDate!,
          detail: item.purchaseStore,
          secondaryDetail: priceStr,
        ));
      }

      // Started
      if (item.startedAt != null) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.started,
          timestamp: item.startedAt!,
        ));
      }

      // Finished
      if (item.finishedAt != null) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.finished,
          timestamp: item.finishedAt!,
        ));
      }

      // Sold
      if (item.soldAt != null) {
        final priceStr = item.sellPriceCents != null
            ? '${(item.sellPriceCents! / 100).toStringAsFixed(2)} ${item.currency ?? ''}'.trim()
            : null;
        events.add(ActivityEvent(
          kind: ActivityEventKind.sold,
          timestamp: item.soldAt!,
          detail: item.soldTo,
          secondaryDetail: priceStr,
        ));
      }

      // Deleted = removed from collection
      if (item.isDeleted && item.deletedAt != null) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.removedFromCollection,
          timestamp: item.deletedAt!,
        ));
      }

      // Added to collection (use updatedAt as proxy if no purchase date)
      if (item.purchaseDate == null && !item.isDeleted) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.addedToCollection,
          timestamp: item.updatedAt,
        ));
      }

      // Rating
      if (item.rating != null) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.rated,
          timestamp: item.updatedAt,
          rating: item.rating,
        ));
      }
    }

    // --- Tracking entry events ---
    for (final entry in trackingEntries) {
      if (entry.isDeleted) continue;

      if (entry.startedAt != null) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.started,
          timestamp: entry.startedAt!,
        ));
      }
      if (entry.finishedAt != null) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.finished,
          timestamp: entry.finishedAt!,
        ));
      }
      if (entry.rating != null) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.rated,
          timestamp: entry.updatedAt,
          rating: entry.rating,
        ));
      }
    }

    // --- Watch sessions ---
    for (final session in watchSessions) {
      if (session.isDeleted) continue;

      final epStr = session.isEpisodeSession
          ? 'S${session.seasonNumber}E${session.episodeNumber}'
          : null;
      events.add(ActivityEvent(
        kind: ActivityEventKind.watched,
        timestamp: session.watchedAt,
        detail: epStr,
        rating: session.rating,
      ));
    }

    // --- Wishlist events ---
    for (final wish in wishlistItems) {
      events.add(ActivityEvent(
        kind: ActivityEventKind.wishlisted,
        timestamp: wish.createdAt,
      ));
    }

    // --- Loan events ---
    for (final loan in loans) {
      events.add(ActivityEvent(
        kind: ActivityEventKind.loaned,
        timestamp: loan.lentDate,
        detail: loan.borrowerName,
      ));
      if (loan.returnedDate != null) {
        events.add(ActivityEvent(
          kind: ActivityEventKind.loanReturned,
          timestamp: loan.returnedDate!,
          detail: loan.borrowerName,
        ));
      }
    }

    // Deduplicate by kind+timestamp (same second = same event from owned vs tracking)
    final seen = <String>{};
    events.removeWhere((e) {
      final key = '${e.kind.name}:${e.timestamp.millisecondsSinceEpoch ~/ 1000}';
      return !seen.add(key);
    });

    // Sort newest first.
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }
}
