import 'package:flutter/material.dart';

/// The kind of activity that occurred for an item.
enum ActivityEventKind {
  addedToCollection,
  removedFromCollection,
  wishlisted,
  purchased,
  started,
  finished,
  sold,
  loaned,
  loanReturned,
  watched,
  rated,
}

/// A single activity event aggregated from various data sources.
class ActivityEvent {
  const ActivityEvent({
    required this.kind,
    required this.timestamp,
    this.detail,
    this.secondaryDetail,
    this.rating,
  });

  final ActivityEventKind kind;
  final DateTime timestamp;

  /// Short description, e.g. borrower name, store name, etc.
  final String? detail;

  /// Extra info, e.g. price, season/episode.
  final String? secondaryDetail;

  /// Star rating if this is a rated event.
  final int? rating;

  String get label => switch (kind) {
        ActivityEventKind.addedToCollection => 'Added to collection',
        ActivityEventKind.removedFromCollection => 'Removed from collection',
        ActivityEventKind.wishlisted => 'Added to wishlist',
        ActivityEventKind.purchased => 'Purchased',
        ActivityEventKind.started => 'Started',
        ActivityEventKind.finished => 'Finished',
        ActivityEventKind.sold => 'Sold',
        ActivityEventKind.loaned => 'Loaned',
        ActivityEventKind.loanReturned => 'Loan returned',
        ActivityEventKind.watched => 'Watched',
        ActivityEventKind.rated => 'Rated',
      };

  IconData get icon => switch (kind) {
        ActivityEventKind.addedToCollection => Icons.add_circle_outline,
        ActivityEventKind.removedFromCollection => Icons.remove_circle_outline,
        ActivityEventKind.wishlisted => Icons.star_border,
        ActivityEventKind.purchased => Icons.shopping_cart_outlined,
        ActivityEventKind.started => Icons.play_arrow_outlined,
        ActivityEventKind.finished => Icons.check_circle_outline,
        ActivityEventKind.sold => Icons.sell_outlined,
        ActivityEventKind.loaned => Icons.person_outline,
        ActivityEventKind.loanReturned => Icons.assignment_return_outlined,
        ActivityEventKind.watched => Icons.visibility_outlined,
        ActivityEventKind.rated => Icons.star,
      };
}
