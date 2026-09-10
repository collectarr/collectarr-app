import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_item_link.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

final class ProviderLocalStateBridge {
  const ProviderLocalStateBridge({
    required this.catalogSummaries,
    required this.trackingLifecycles,
    required this.wishlist,
  });

  final CatalogDisplaySummaryRepository catalogSummaries;
  final TrackingLifecycleRepository trackingLifecycles;
  final WishlistItemsCacheRepository wishlist;

  Future<ProviderPersonalEntry?> read(
    CatalogEntityRef localRef, {
    ProviderItemLink? link,
  }) async {
    final tracking = await _findTracking(localRef);
    final catalog = await catalogSummaries.findByRef(localRef);
    if (tracking != null) {
      return _fromTracking(localRef, tracking, catalog?.title, link: link);
    }

    final wishlistItem = await _findWishlist(localRef);
    if (wishlistItem == null) {
      return null;
    }
    return ProviderPersonalEntry(
      provider: link?.provider ?? ProviderId.aniList,
      remoteItemId: link?.remoteItemId ?? localRef.id,
      remoteEntryId: link?.remoteEntryId,
      kind: localRef.kind,
      title: catalog?.title,
      status: ProviderEntryStatus.planning,
      notes: wishlistItem.notes,
    );
  }

  Future<TrackingSummary?> _findTracking(CatalogEntityRef localRef) async {
    final summaries = await trackingLifecycles.listActiveSummaries();
    for (final summary in summaries) {
      if (matches(summary.catalogRef, localRef)) {
        return summary;
      }
    }
    return null;
  }

  Future<WishlistItem?> _findWishlist(CatalogEntityRef localRef) async {
    final items = await wishlist.listActive();
    for (final item in items) {
      if (matches(item.catalogRef, localRef)) {
        return item;
      }
    }
    return null;
  }

  ProviderPersonalEntry _fromTracking(
    CatalogEntityRef localRef,
    TrackingSummary entry,
    String? title, {
    ProviderItemLink? link,
  }) {
    return ProviderPersonalEntry(
      provider: link?.provider ?? ProviderId.aniList,
      remoteItemId: link?.remoteItemId ?? localRef.id,
      remoteEntryId: link?.remoteEntryId,
      kind: localRef.kind,
      title: title,
      status: _providerStatus(entry.status),
      rating: entry.rating == null ? null : entry.rating! * 10,
      progress: entry.progressCurrent,
      totalProgress: entry.progressTotal,
      startedAt: entry.startedAt,
      completedAt: entry.completedAt,
      repeatCount: entry.timesCompleted ?? 0,
      notes: entry.notes,
    );
  }

  ProviderEntryStatus? _providerStatus(MediaTrackingStatus? status) {
    return switch (status) {
      MediaTrackingStatus.planned => ProviderEntryStatus.planning,
      MediaTrackingStatus.inProgress => ProviderEntryStatus.current,
      MediaTrackingStatus.completed => ProviderEntryStatus.completed,
      MediaTrackingStatus.paused => ProviderEntryStatus.paused,
      MediaTrackingStatus.dropped => ProviderEntryStatus.dropped,
      MediaTrackingStatus.repeating => ProviderEntryStatus.repeating,
      MediaTrackingStatus.none || null => null,
    };
  }

  bool matches(CatalogEntityRef left, CatalogEntityRef right) {
    return left.id == right.id &&
        left.entityType == right.entityType &&
        (left.kind == right.kind || left.kind.isUnknown);
  }
}
