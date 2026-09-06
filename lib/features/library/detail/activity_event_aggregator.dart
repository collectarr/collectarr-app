import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/activity/universal_activity_contributors.dart';

/// Aggregates [ActivityEvent]s for a single catalog item from the various
/// domain models that carry date information.
class ActivityEventAggregator {
  const ActivityEventAggregator._();

  /// Build a time-sorted (newest-first) list of activity events for one item.
  static List<ActivityEvent> aggregate({
    required List<OwnedItem> ownedItems,
    required List<TrackingEntry> trackingEntries,
    required List<WishlistItem> wishlistItems,
    required List<Loan> loans,
    Iterable<WatchSession> watchSessions = const <WatchSession>[],
    UniversalActivityKindPredicate hasKindContributor =
        _noKindActivityContributor,
    Iterable<ActivityEvent> kindEvents = const <ActivityEvent>[],
  }) {
    final universalContext = UniversalActivityContext(
      ownedItems: ownedItems,
      trackingEntries: trackingEntries,
      wishlistItems: wishlistItems,
      loans: loans,
      watchSessions: watchSessions,
      hasKindContributor: hasKindContributor,
    );
    final events = <ActivityEvent>[];
    for (final contributor in universalActivityContributors) {
      events.addAll(contributor.contribute(universalContext));
    }
    events.addAll(kindEvents);

    // Deduplicate by kind+timestamp (same second = same event from owned vs tracking)
    final seen = <String>{};
    events.removeWhere((e) {
      final key =
          '${e.kind.name}:${e.timestamp.millisecondsSinceEpoch ~/ 1000}';
      return !seen.add(key);
    });

    // Sort newest first.
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }
}

bool _noKindActivityContributor(CatalogMediaKind kind) => false;
