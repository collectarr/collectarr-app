import 'dart:async';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/mutations/collection_import_service.dart';
import 'package:collectarr_app/features/collection/mutations/custom_episode_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/metadata_override_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/watch_session_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/collection/events/collection_event.dart';
export 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
export 'package:collectarr_app/features/collection/mutations/collection_import_service.dart' hide IdGenerator;
export 'package:collectarr_app/features/collection/mutations/custom_episode_mutations.dart' hide IdGenerator;
export 'package:collectarr_app/features/collection/mutations/metadata_override_mutations.dart' hide IdGenerator;
export 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart' hide IdGenerator;
export 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart' hide IdGenerator;
export 'package:collectarr_app/features/collection/mutations/watch_session_mutations.dart' hide IdGenerator;
export 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart' hide IdGenerator;
export 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
export 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';

class CollectionMutations {
  CollectionMutations(this.ref);

  final Ref ref;

  OwnedItemMutations get _owned => ref.read(ownedItemMutationsProvider);
  WishlistMutations get _wishlist => ref.read(wishlistMutationsProvider);
  TrackingMutations get _tracking => ref.read(trackingMutationsProvider);
  WatchSessionMutations get _watch => ref.read(watchSessionMutationsProvider);
  MetadataOverrideMutations get _override => ref.read(metadataOverrideMutationsProvider);
  CustomEpisodeMutations get _episode => ref.read(customEpisodeMutationsProvider);
  CollectionImportService get _import => ref.read(collectionImportServiceProvider);

  // ─── Owned Items ──────────────────────────────────────────────────────────

  Future<OwnedItem> addOwnedItem(
    AddOwnedItemCommand command, {
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final item = await _owned.addOwnedItem(
      command,
      syncTracking: syncTracking,
      notify: notify,
    );
    final hasTrackingInfo = command.common.rating != null ||
        command.common.readStatus != null ||
        command.common.startedAt != null ||
        command.common.finishedAt != null;
    if (syncTracking && hasTrackingInfo) {
      await _tracking.syncOwnedTrackingEntry(item);
    }
    unawaited(ref.read(syncControllerProvider.notifier).syncOnlineFirstIfEnabled());
    return item;
  }

  Future<OwnedItem> updateOwnedItem(
    UpdateOwnedItemCommand command, {
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final item = await _owned.updateOwnedItem(
      command,
      syncTracking: syncTracking,
      notify: notify,
    );
    if (syncTracking) {
      await _tracking.syncOwnedTrackingEntry(item);
    }
    unawaited(ref.read(syncControllerProvider.notifier).syncOnlineFirstIfEnabled());
    return item;
  }

  Future<void> updateCatalogSnapshot(
    CatalogItem item, {
    bool notify = true,
  }) =>
      _owned.updateCatalogSnapshot(item, notify: notify);

  Future<void> updateCatalogSnapshots(
    Iterable<CatalogItem> items, {
    bool notify = true,
  }) =>
      _owned.updateCatalogSnapshots(items, notify: notify);

  Future<void> removeItem(OwnedItem item, {bool notify = true}) =>
      _owned.removeItem(item, notify: notify);

  Future<int> promoteLocalOnlyItemToCatalog(
    String localItemId,
    CatalogItem targetCatalogItem,
  ) =>
      _owned.promoteLocalOnlyItemToCatalog(localItemId, targetCatalogItem);

  // ─── Wishlist ─────────────────────────────────────────────────────────────

  Future<void> addToWishlist(
    String itemId, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) =>
      _wishlist.addToWishlist(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        notify: notify,
      );

  Future<void> addLocalOnlyWishlistItem(
    CatalogItem item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) =>
      _wishlist.addLocalOnlyWishlistItem(
        item,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        notify: notify,
      );

  Future<WishlistItem> updateWishlistItem(
    WishlistItem item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    int? targetPriceCents,
    String? currency,
    String? notes,
    bool notify = true,
  }) =>
      _wishlist.updateWishlistItem(
        item,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        targetPriceCents: targetPriceCents,
        currency: currency,
        notes: notes,
        notify: notify,
      );

  Future<void> removeFromWishlist(
    String itemId, {
    String? wishlistItemId,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) =>
      _wishlist.removeFromWishlist(
        itemId,
        wishlistItemId: wishlistItemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        notify: notify,
      );

  Future<void> toggleWishlist(
    String itemId, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) =>
      _wishlist.toggleWishlist(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );

  // ─── Tracking ─────────────────────────────────────────────────────────────

  Future<void> updateTrackingEntry(TrackingEntry entry) =>
      _tracking.updateTrackingEntry(entry);

  Future<void> upsertTrackingEntry(
    Object target, {
    String? ownedItemId,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    Object? sourceType,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    int? seasonNumber,
    int? episodeNumber,
    Map<Object, int>? episodeRatings,
    bool allowEmpty = false,
    bool notify = true,
  }) =>
      _tracking.upsertTrackingEntry(
        target,
        ownedItemId: ownedItemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        sourceType: sourceType,
        status: status,
        rating: rating,
        startedAt: startedAt,
        finishedAt: finishedAt,
        progressCurrent: progressCurrent,
        progressTotal: progressTotal,
        timesCompleted: timesCompleted,
        notes: notes,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        episodeRatings: episodeRatings,
        allowEmpty: allowEmpty,
        notify: notify,
      );

  Future<void> deleteTrackingEntry(TrackingEntry entry, {bool notify = true}) =>
      _tracking.deleteTrackingEntry(entry, notify: notify);

  Future<void> removeTrackingEntry(TrackingEntry entry, {bool notify = true}) =>
      _tracking.removeTrackingEntry(entry, notify: notify);

  Future<void> syncOwnedTrackingEntry(
    OwnedItem item, {
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    int? seasonNumber,
    int? episodeNumber,
    Map<Object, int>? episodeRatings,
  }) =>
      _tracking.syncOwnedTrackingEntry(
        item,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        status: status,
        rating: rating,
        startedAt: startedAt,
        finishedAt: finishedAt,
        progressCurrent: progressCurrent,
        progressTotal: progressTotal,
        timesCompleted: timesCompleted,
        notes: notes,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        episodeRatings: episodeRatings,
      );

  Future<void> addLocalOnlyTrackingEntry(
    CatalogItem item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    Object? sourceType,
    Object? status = MediaTrackingStatus.planned,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    int? seasonNumber,
    int? episodeNumber,
    Map<Object, int>? episodeRatings,
    bool allowEmpty = false,
  }) =>
      _tracking.addLocalOnlyTrackingEntry(
        item,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        sourceType: sourceType,
        status: status,
        rating: rating,
        startedAt: startedAt,
        finishedAt: finishedAt,
        progressCurrent: progressCurrent,
        progressTotal: progressTotal,
        timesCompleted: timesCompleted,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        episodeRatings: episodeRatings,
        allowEmpty: allowEmpty,
      );

  Future<void> syncTrackingUnit(TrackingUnit unit) =>
      _tracking.syncTrackingUnit(unit);

  Future<void> setTrackingEpisodeCompleted(
    CatalogEntityRef seriesRef, {
    required int seasonNumber,
    required int episodeNumber,
    bool isCompleted = true,
    bool? completed,
  }) =>
      _tracking.setTrackingEpisodeCompleted(
        seriesRef,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        isCompleted: isCompleted,
        completed: completed,
      );

  Future<void> setSeasonEpisodesCompleted(
    CatalogEntityRef seriesRef, {
    required int seasonNumber,
    int? episodeCount,
    Iterable<int>? episodeNumbers,
    bool isCompleted = true,
    bool? completed,
  }) =>
      _tracking.setSeasonEpisodesCompleted(
        seriesRef,
        seasonNumber: seasonNumber,
        episodeCount: episodeCount,
        episodeNumbers: episodeNumbers,
        isCompleted: isCompleted,
        completed: completed,
      );

  // ─── Watch Sessions ───────────────────────────────────────────────────────

  Future<WatchSession> addWatchSession(
    CatalogEntityRef targetRef, {
    String? id,
    String? trackingEntryId,
    int? seasonNumber,
    int? episodeNumber,
    Object? sourceType,
    DateTime? watchedAt,
    String? seenWhere,
    int? rating,
    String? notes,
  }) =>
      _watch.addWatchSession(
        targetRef,
        id: id,
        trackingEntryId: trackingEntryId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        sourceType: sourceType,
        watchedAt: watchedAt,
        seenWhere: seenWhere,
        rating: rating,
        notes: notes,
      );

  Future<void> removeWatchSession(WatchSession session) =>
      _watch.removeWatchSession(session);

  // ─── Metadata Overrides ───────────────────────────────────────────────────

  Future<UserMetadataOverride> setMetadataOverride(
    String itemId, {
    required String fieldPath,
    required String overrideValue,
    String? originalValue,
    String? editionId,
    String? variantId,
  }) =>
      _override.setMetadataOverride(
        itemId,
        fieldPath: fieldPath,
        overrideValue: overrideValue,
        originalValue: originalValue,
        editionId: editionId,
        variantId: variantId,
      );

  Future<void> removeMetadataOverride(UserMetadataOverride override) =>
      _override.removeMetadataOverride(override);

  // ─── Custom Episodes ──────────────────────────────────────────────────────

  Future<CustomEpisode> upsertCustomEpisode({
    String? id,
    required CatalogEntityRef catalogRef,
    required int seasonNumber,
    required int episodeNumber,
    required String title,
    String? overview,
    String? airDate,
    int? runtimeMinutes,
    String? stillImageUrl,
    String? localImagePath,
    String? thumbnailImageUrl,
  }) =>
      _episode.upsertCustomEpisode(
        id: id,
        catalogRef: catalogRef,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        title: title,
        overview: overview,
        airDate: airDate,
        runtimeMinutes: runtimeMinutes,
        stillImageUrl: stillImageUrl,
        localImagePath: localImagePath,
        thumbnailImageUrl: thumbnailImageUrl,
      );

  Future<void> removeCustomEpisode(CustomEpisode episode) =>
      _episode.removeCustomEpisode(episode);

  // ─── Imports ──────────────────────────────────────────────────────────────

  Future<int> importRows(List<CollectionCsvRow> rows) =>
      _import.importRows(rows);

  Future<CollectionImportPreview> previewImportRows(List<CollectionCsvRow> rows) =>
      _import.previewImportRows(rows);
}

final collectionMutationsProvider = Provider<CollectionMutations>((ref) {
  return CollectionMutations(ref);
});
