import 'dart:async';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/services/image_download_service.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const Object _updateItemUnset = Object();

class CollectionMutations {
  CollectionMutations(this.ref);

  final Ref ref;
  final Uuid _uuid = const Uuid();
  final Set<String> _pendingCoverDownloads = <String>{};

  Future<OwnedItem> addItem(
    String itemId, {
    bool? isDigital,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int quantity = 1,
    String? locationId,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    String? labelType,
    String? certificationNumber,
    bool keyComic = false,
    String? keyReason,
    int? rating,
    String? readStatus,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? tags,
    DateTime? soldAt,
    int? sellPriceCents,
    String? soldTo,
    String? features,
    List<String>? hdrFormats,
    String? purchaseStore,
    String? boxSetId,
    String? boxSetName,
    String? storageDevice,
    String? storageSlot,
    String? region,
    String? packaging,
    String? distributor,
    String? collectionStatus,
    DateTime? lastBagBoardDate,
    int? marketValueCents,
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final auth = ref.read(authControllerProvider);
    final catalogItem = await _catalogCache().findById(itemId);
    final resolvedIsDigital =
        isDigital ?? await _resolveOwnedDigitalFlag(itemId: itemId);
    final normalizedAnchorType = _normalizedPersonalAnchorType(
      anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    final ownedItem = OwnedItem(
      id: _uuid.v4(),
      catalogRef: _catalogRefForItem(
        itemId,
        catalogItem,
        anchorType: normalizedAnchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      ),
      createdAt: now,
      isDigital: resolvedIsDigital,
      anchorType: normalizedAnchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      quantity: quantity,
      locationId: locationId,
      indexNumber: indexNumber,
      coverPriceCents: coverPriceCents,
      rawOrSlabbed: rawOrSlabbed,
      gradingCompany: gradingCompany,
      graderNotes: graderNotes,
      signedBy: signedBy,
      labelType: labelType,
      certificationNumber: certificationNumber,
      keyComic: keyComic,
      keyReason: keyReason,
      rating: rating,
      readStatus: readStatus,
      startedAt: startedAt,
      finishedAt: finishedAt,
      tags: tags,
      soldAt: soldAt,
      sellPriceCents: sellPriceCents,
      soldTo: soldTo,
      ownerUserId: auth.userId,
      ownerLabel: auth.email,
      features: features,
      hdrFormats: hdrFormats ?? const <String>[],
      purchaseStore: purchaseStore,
      boxSetId: boxSetId,
      boxSetName: boxSetName,
      storageDevice: storageDevice,
      storageSlot: storageSlot,
      region: region,
      packaging: packaging,
      distributor: distributor,
      collectionStatus: collectionStatus,
      lastBagBoardDate: lastBagBoardDate,
      marketValueCents: marketValueCents,
      updatedAt: now,
    );
    await _ownedCache().upsert(ownedItem);
    await _enqueueOwnedItem(ownedItem, 'upsert', now);
    if (syncTracking) {
      await _syncTrackingForOwnedItem(ownedItem, now);
    }
    await _enqueueCatalogSnapshotForItemId(itemId, now);
    // Download cover image bytes in the background.
    unawaited(_downloadCoverForOwnedItem(ownedItem.id, itemId));
    final wishlistItems = await _wishlistItemsForMutation(
      itemId,
      anchorType: normalizedAnchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    for (final wishlistItem in wishlistItems) {
      await _wishlistCache().markDeleted(wishlistItem, now);
      await _enqueueWishlistItem(
        wishlistItem.copyWith(updatedAt: now, deletedAt: now),
        'delete',
        now,
      );
    }
    if (notify) {
      await _notifyCollectionChanged(wishlistChanged: wishlistItems.isNotEmpty);
    }
    return ownedItem;
  }

  Future<OwnedItem> updateItem(
    OwnedItem item, {
    bool? isDigital,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    Object? locationId = _updateItemUnset,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    String? labelType,
    String? customLabel,
    String? pageQuality,
    String? certificationNumber,
    bool? keyComic,
    String? keyReason,
    String? keyCategory,
    String? keySeverity,
    int? rating,
    String? readStatus,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? tags,
    DateTime? soldAt,
    int? sellPriceCents,
    String? soldTo,
    String? features,
    List<String>? hdrFormats,
    String? purchaseStore,
    String? boxSetId,
    String? boxSetName,
    String? storageDevice,
    String? storageSlot,
    String? region,
    String? packaging,
    String? distributor,
    String? collectionStatus,
    DateTime? lastBagBoardDate,
    int? marketValueCents,
    String? ownerLabel,
    String? gameCompleteness,
    bool? gameHasBox,
    bool? gameHasManual,
    String? gamePriceChartingId,
    String? gameCoreRegion,
    bool? gameValueIsLocked,
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final auth = ref.read(authControllerProvider);
    final resolvedIsDigital = isDigital ??
        item.isDigital ??
        await _resolveOwnedDigitalFlag(itemId: item.itemId);
    final normalizedAnchorType = _normalizedPersonalAnchorType(
      anchorType ?? item.anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      fallbackEditionId: item.editionId,
      fallbackVariantId: item.variantId,
      fallbackBundleReleaseId: item.bundleReleaseId,
    );
    final updated = OwnedItem(
      id: item.id,
      catalogRef: item.catalogRef,
      createdAt: item.createdAt ?? now,
      isDigital: resolvedIsDigital,
      anchorType: normalizedAnchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId ?? item.bundleReleaseId,
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      quantity: quantity ?? item.quantity,
      indexNumber: indexNumber,
      coverPriceCents: coverPriceCents,
      rawOrSlabbed: rawOrSlabbed,
      gradingCompany: gradingCompany,
      graderNotes: graderNotes,
      signedBy: signedBy,
      labelType: labelType,
      customLabel: customLabel,
      pageQuality: pageQuality,
      certificationNumber: certificationNumber,
      keyComic: keyComic ?? item.keyComic,
      keyReason: keyReason,
      keyCategory: keyCategory,
      keySeverity: keySeverity,
      rating: rating,
      readStatus: readStatus,
      startedAt: startedAt,
      finishedAt: finishedAt,
      tags: tags,
      soldAt: soldAt,
      sellPriceCents: sellPriceCents,
      soldTo: soldTo,
      ownerUserId: item.ownerUserId ?? auth.userId,
      ownerLabel: ownerLabel ?? item.ownerLabel ?? auth.email,
      locationId: identical(locationId, _updateItemUnset)
          ? item.locationId
          : locationId as String?,
      updatedAt: now,
      deletedAt: item.deletedAt,
      features: features,
      hdrFormats: hdrFormats ?? item.hdrFormats,
      purchaseStore: purchaseStore,
      boxSetId: boxSetId,
      boxSetName: boxSetName,
      storageDevice: storageDevice,
      storageSlot: storageSlot,
      region: region,
      packaging: packaging,
      distributor: distributor,
      collectionStatus: collectionStatus ?? item.collectionStatus,
      lastBagBoardDate: lastBagBoardDate ?? item.lastBagBoardDate,
      marketValueCents: marketValueCents ?? item.marketValueCents,
      gameCompleteness: gameCompleteness ?? item.gameCompleteness,
      gameHasBox: gameHasBox ?? item.gameHasBox,
      gameHasManual: gameHasManual ?? item.gameHasManual,
      gamePriceChartingId: gamePriceChartingId ?? item.gamePriceChartingId,
      gameCoreRegion: gameCoreRegion ?? item.gameCoreRegion,
      gameValueIsLocked: gameValueIsLocked ?? item.gameValueIsLocked,
    );
    await _ownedCache().upsert(updated);
    await _enqueueOwnedItem(updated, 'upsert', now);
    if (syncTracking) {
      await _syncTrackingForOwnedItem(updated, now);
    }
    if (notify) {
      await _notifyCollectionChanged();
    }
    return updated;
  }

  Future<void> syncOwnedTrackingEntry(
    OwnedItem ownedItem, {
    String? editionId,
    String? variantId,
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
    Map<String, int>? episodeRatings,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final entry = TrackingEntry(
      id: _trackingEntryIdForOwnedItem(ownedItem.id),
      itemId: ownedItem.itemId,
      catalogRef: _trackingCatalogRefForItemId(
        ownedItem.itemId,
        sourceType: TrackingSourceType.physical.apiValue,
        editionId: editionId ?? ownedItem.editionId,
        variantId: variantId ?? ownedItem.variantId,
        bundleReleaseId: ownedItem.bundleReleaseId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      ),
      ownedItemId: ownedItem.id,
      editionId: editionId ?? ownedItem.editionId,
      variantId: variantId ?? ownedItem.variantId,
      sourceType: TrackingSourceType.physical,
      status: _normalizeTrackingStatusValue(status),
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: _normalizeTrackingValue(notes),
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      episodeRatings: episodeRatings,
      updatedAt: now,
    );
    await _syncTrackingEntry(entry, now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> upsertTrackingEntry(
    String itemId, {
    String? ownedItemId,
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
    bool allowEmpty = false,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final normalizedSourceType = _normalizeTrackingSourceTypeValue(sourceType);
    String entryId;
    if (ownedItemId != null) {
      entryId = _trackingEntryIdForOwnedItem(ownedItemId);
    } else {
      TrackingEntry? existingEntry;
      final existingEntries =
          await _trackingCache().findActiveByItemIds([itemId]);
      for (final candidate in existingEntries) {
        if (candidate.ownedItemId != null) {
          continue;
        }
        if (candidate.sourceTypeApiValue == normalizedSourceType) {
          existingEntry = candidate;
          break;
        }
      }
      entryId = existingEntry?.id ??
          _trackingEntryIdForItem(itemId, sourceType: normalizedSourceType);
    }
    final entry = TrackingEntry(
      id: entryId,
      catalogRef: _trackingCatalogRefForItemId(
        itemId,
        sourceType: normalizedSourceType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      ),
      ownedItemId: ownedItemId,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      sourceType: normalizedSourceType,
      status: _normalizeTrackingStatusValue(status),
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: _normalizeTrackingValue(notes),
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      updatedAt: now,
    );
    await _syncTrackingEntry(entry, now, allowEmpty: allowEmpty);
    await _enqueueCatalogSnapshotForItemId(itemId, now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> setTrackingEpisodeCompleted(
    String itemId, {
    required int seasonNumber,
    required int episodeNumber,
    required bool completed,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final unitId = _trackingUnitIdForEpisode(
      itemId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );
    final existingUnit = await _trackingUnitsCache().findById(unitId);
    if (completed) {
      final trackingEntries =
          await _trackingCache().findActiveByItemIds([itemId]);
      final summaryEntry = _summaryTrackingEntryForItem(trackingEntries);
      await _trackingUnitsCache().upsert(
        TrackingUnit(
          id: unitId,
          itemId: itemId,
          trackingEntryId: summaryEntry?.id,
          ownedItemId: summaryEntry?.ownedItemId,
          editionId: summaryEntry?.editionId,
          variantId: summaryEntry?.variantId,
          bundleReleaseId: summaryEntry?.bundleReleaseId,
          unitType: TrackingUnitType.episode,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          completedAt: now,
          updatedAt: now,
        ),
      );
      // T6: Record a watch session for this episode.
      final session = WatchSession(
        id: _uuid.v4(),
        itemId: itemId,
        trackingEntryId: summaryEntry?.id,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        watchedAt: now,
        updatedAt: now,
      );
      await _watchSessionsCache().upsert(session);
      await _enqueueWatchSession(session, 'upsert', now);
    } else if (existingUnit != null && !existingUnit.isDeleted) {
      await _trackingUnitsCache().markDeleted(existingUnit, now);
    }
    await _reconcileTrackingEntryFromUnits(itemId, changedAt: now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> setSeasonEpisodesCompleted(
    String itemId, {
    required int seasonNumber,
    required Iterable<int> episodeNumbers,
    required bool completed,
    bool notify = true,
  }) async {
    final normalizedEpisodes = episodeNumbers
        .where((value) => value > 0)
        .toSet()
        .toList(growable: false)
      ..sort();
    if (normalizedEpisodes.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc();
    if (completed) {
      final trackingEntries =
          await _trackingCache().findActiveByItemIds([itemId]);
      final summaryEntry = _summaryTrackingEntryForItem(trackingEntries);
      await _trackingUnitsCache().upsertAll(
        normalizedEpisodes.map(
          (episodeNumber) => TrackingUnit(
            id: _trackingUnitIdForEpisode(
              itemId,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
            ),
            itemId: itemId,
            trackingEntryId: summaryEntry?.id,
            ownedItemId: summaryEntry?.ownedItemId,
            editionId: summaryEntry?.editionId,
            variantId: summaryEntry?.variantId,
            bundleReleaseId: summaryEntry?.bundleReleaseId,
            unitType: TrackingUnitType.episode,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            completedAt: now,
            updatedAt: now,
          ),
        ),
      );
    } else {
      await _trackingUnitsCache().markDeletedByIds(
        normalizedEpisodes.map(
          (episodeNumber) => _trackingUnitIdForEpisode(
            itemId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
          ),
        ),
        now,
      );
    }
    await _reconcileTrackingEntryFromUnits(itemId, changedAt: now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> addLocalOnlyTrackingEntry(
    CatalogItem item, {
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
    bool allowEmpty = false,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await _catalogCache().upsertAll([item]);
    final normalizedSourceType = _normalizeTrackingSourceTypeValue(sourceType);
    TrackingEntry? existingEntry;
    final existingEntries =
        await _trackingCache().findActiveByItemIds([item.id]);
    for (final candidate in existingEntries) {
      if (candidate.ownedItemId != null) {
        continue;
      }
      if (candidate.sourceTypeApiValue == normalizedSourceType) {
        existingEntry = candidate;
        break;
      }
    }
    final entry = TrackingEntry(
      id: existingEntry?.id ??
          _trackingEntryIdForItem(item.id, sourceType: normalizedSourceType),
      catalogRef: _catalogRefForItem(item.id, item),
      sourceType: normalizedSourceType,
      status: _normalizeTrackingStatusValue(status),
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: _normalizeTrackingValue(notes),
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      updatedAt: now,
    );
    if (!_hasTrackingData(entry) && !allowEmpty) {
      return;
    }
    await _trackingCache().upsert(entry);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> updateCatalogSnapshot(
    CatalogItem item, {
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await _catalogCache().upsertAll([item]);
    await _syncQueue().enqueue(_syncChangeForCatalogItem(item, now));
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> updateCatalogSnapshots(
    Iterable<CatalogItem> items, {
    bool notify = true,
  }) async {
    final pendingItems = items.toList(growable: false);
    if (pendingItems.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc();
    await _catalogCache().upsertAll(pendingItems);
    await _syncQueue().enqueueAll([
      for (final item in pendingItems) _syncChangeForCatalogItem(item, now),
    ]);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> removeItem(OwnedItem item, {bool notify = true}) async {
    final now = DateTime.now().toUtc();
    await _ownedCache().markDeleted(item, now);
    await _enqueueOwnedItem(
        item.copyWith(updatedAt: now, deletedAt: now), 'delete', now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> removeTrackingEntry(TrackingEntry entry,
      {bool notify = true}) async {
    final now = DateTime.now().toUtc();
    final deleted = _trackingDeletion(entry, now);
    await _trackingCache().markDeleted(entry, now);
    await _enqueueTrackingEntry(deleted, 'delete', now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  // ─── Watch Sessions ─────────────────────────────────────────────────

  Future<WatchSession> addWatchSession(
    String itemId, {
    String? trackingEntryId,
    int? seasonNumber,
    int? episodeNumber,
    TrackingSourceType? sourceType,
    DateTime? watchedAt,
    int? rating,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final session = WatchSession(
      id: _uuid.v4(),
      itemId: itemId,
      trackingEntryId: trackingEntryId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      sourceType: sourceType,
      watchedAt: watchedAt ?? now,
      rating: rating,
      notes: notes,
      updatedAt: now,
    );
    await _watchSessionsCache().upsert(session);
    await _enqueueWatchSession(session, 'upsert', now);
    await _notifyCollectionChanged();
    return session;
  }

  Future<void> removeWatchSession(WatchSession session) async {
    final now = DateTime.now().toUtc();
    await _watchSessionsCache().markDeleted(session, now);
    final deleted = session.copyWith(deletedAt: now, updatedAt: now);
    await _enqueueWatchSession(deleted, 'delete', now);
    await _notifyCollectionChanged();
  }

  // ─── Metadata Overrides ─────────────────────────────────────────────

  /// Create or update a user metadata override for a catalog field.
  ///
  /// If an active override already exists for the same (item, field, edition?,
  /// variant?) combination, it is updated in-place.
  Future<UserMetadataOverride> setMetadataOverride(
    String itemId, {
    required String fieldPath,
    required String overrideValue,
    String? originalValue,
    String? editionId,
    String? variantId,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await _overridesCache().findByField(
      itemId,
      fieldPath,
      editionId: editionId,
      variantId: variantId,
    );
    final override = UserMetadataOverride(
      id: existing?.id ?? _uuid.v4(),
      itemId: itemId,
      editionId: editionId,
      variantId: variantId,
      fieldPath: fieldPath,
      originalValue: originalValue ?? existing?.originalValue,
      overrideValue: overrideValue,
      updatedAt: now,
    );
    await _overridesCache().upsert(override);
    await _enqueueMetadataOverride(override, 'upsert', now);
    await _notifyCollectionChanged();
    return override;
  }

  /// Remove (soft-delete) a metadata override, restoring the catalog value.
  Future<void> removeMetadataOverride(UserMetadataOverride override) async {
    final now = DateTime.now().toUtc();
    await _overridesCache().markDeleted(override, now);
    final deleted = override.copyWith(deletedAt: now, updatedAt: now);
    await _enqueueMetadataOverride(deleted, 'delete', now);
    await _notifyCollectionChanged();
  }

  // ─── Custom Episodes ────────────────────────────────────────────────

  /// Create or update a custom episode for a series.
  Future<CustomEpisode> upsertCustomEpisode({
    String? id,
    required String itemId,
    required int seasonNumber,
    required int episodeNumber,
    required String title,
    String? overview,
    String? airDate,
    int? runtimeMinutes,
  }) async {
    final now = DateTime.now().toUtc();
    final episode = CustomEpisode(
      id: id ?? _uuid.v4(),
      itemId: itemId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      title: title,
      overview: overview,
      airDate: airDate,
      runtimeMinutes: runtimeMinutes,
      updatedAt: now,
    );
    await _customEpisodesCache().upsert(episode);
    await _enqueueCustomEpisode(episode, 'upsert', now);
    await _notifyCollectionChanged();
    return episode;
  }

  /// Remove (soft-delete) a custom episode.
  Future<void> removeCustomEpisode(CustomEpisode episode) async {
    final now = DateTime.now().toUtc();
    await _customEpisodesCache().markDeleted(episode, now);
    final deleted = episode.copyWith(deletedAt: now, updatedAt: now);
    await _enqueueCustomEpisode(deleted, 'delete', now);
    await _notifyCollectionChanged();
  }

  Future<void> addToWishlist(
    String itemId, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final catalogItem = await _catalogCache().findById(itemId);
    final existing = await _wishlistCache().findActiveByItemAnchor(
      itemId,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (existing == null) {
      final normalizedAnchorType = _normalizedPersonalAnchorType(
        anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
      final item = WishlistItem(
        id: _uuid.v4(),
        itemId: itemId,
        catalogRef: _catalogRefForItem(
          itemId,
          catalogItem,
          anchorType: normalizedAnchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
        ),
        anchorType: normalizedAnchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        createdAt: now,
        updatedAt: now,
      );
      await _wishlistCache().upsert(item);
      await _enqueueWishlistItem(item, 'upsert', now);
      await _enqueueCatalogSnapshotForItemId(itemId, now);
    }
    if (notify) {
      await _notifyWishlistChanged();
    }
  }

  Future<void> addLocalOnlyWishlistItem(
    CatalogItem item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await _catalogCache().upsertAll([item]);
    final existing = await _wishlistCache().findActiveByItemAnchor(
      item.id,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (existing == null) {
      final normalizedAnchorType = _normalizedPersonalAnchorType(
        anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
      await _wishlistCache().upsert(
        WishlistItem(
          id: _uuid.v4(),
          itemId: item.id,
          catalogRef: _catalogRefForItem(
            item.id,
            item,
            anchorType: normalizedAnchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
          ),
          anchorType: normalizedAnchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    if (notify) {
      await _notifyWishlistChanged();
    }
  }

  Future<int> promoteLocalOnlyItemToCatalog(
    String localItemId,
    CatalogItem item, {
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final localTrackingEntries =
        await _trackingCache().findActiveByItemIds([localItemId]);
    final localWishlistItems =
        await _wishlistCache().findActiveByItemIds([localItemId]);
    final localTrackingUnits =
        await _trackingUnitsCache().findActiveByItemIds([localItemId]);
    if (localTrackingEntries.isEmpty &&
        localWishlistItems.isEmpty &&
        localTrackingUnits.isEmpty) {
      return 0;
    }

    final targetTrackingEntries =
        await _trackingCache().findActiveByItemIds([item.id]);
    final targetWishlistItems =
        await _wishlistCache().findActiveByItemIds([item.id]);
    final trackingUpserts = <TrackingEntry>[];
    final trackingDeletes = <TrackingEntry>[];
    final wishlistUpserts = <WishlistItem>[];
    final wishlistDeletes = <WishlistItem>[];
    final syncChanges = <SyncChange>[];

    for (final localEntry
        in localTrackingEntries.where((entry) => entry.ownedItemId == null)) {
      TrackingEntry? targetEntry;
      for (final candidate in targetTrackingEntries) {
        if (candidate.ownedItemId != null) {
          continue;
        }
        if (candidate.sourceTypeApiValue == localEntry.sourceTypeApiValue) {
          targetEntry = candidate;
          break;
        }
      }
      if (targetEntry != null) {
        final merged = _mergeTrackingEntryForPromotion(
          targetEntry,
          localEntry,
          itemId: item.id,
          changedAt: now,
        );
        trackingUpserts.add(merged);
        syncChanges.add(_syncChangeForTrackingEntry(merged, 'upsert', now));
        trackingDeletes.add(_trackingDeletion(localEntry, now));
      } else {
        final promoted = localEntry.copyWith(
          itemId: item.id,
          updatedAt: now,
          deletedAt: null,
        );
        trackingUpserts.add(promoted);
        syncChanges.add(_syncChangeForTrackingEntry(promoted, 'upsert', now));
      }
    }

    for (final localWishlist in localWishlistItems) {
      final targetWishlistItem = _findMatchingWishlistItem(
        targetWishlistItems,
        localWishlist,
      );
      if (targetWishlistItem != null) {
        final merged = _mergeWishlistItemForPromotion(
          targetWishlistItem,
          localWishlist,
          itemId: item.id,
          changedAt: now,
        );
        wishlistUpserts.add(merged);
        syncChanges.add(_syncChangeForWishlistItem(merged, 'upsert', now));
        wishlistDeletes
            .add(localWishlist.copyWith(updatedAt: now, deletedAt: now));
      } else {
        final promoted = localWishlist.copyWith(
          itemId: item.id,
          updatedAt: now,
          deletedAt: null,
        );
        wishlistUpserts.add(promoted);
        syncChanges.add(_syncChangeForWishlistItem(promoted, 'upsert', now));
      }
    }

    final trackingUnitUpserts = <TrackingUnit>[];
    final trackingUnitDeletes = <TrackingUnit>[];
    for (final localUnit in localTrackingUnits) {
      final newUnitId = _trackingUnitIdForEpisode(
        item.id,
        seasonNumber: localUnit.seasonNumber ?? 0,
        episodeNumber: localUnit.episodeNumber ?? 0,
      );
      trackingUnitUpserts.add(TrackingUnit(
        id: newUnitId,
        itemId: item.id,
        trackingEntryId: localUnit.trackingEntryId,
        ownedItemId: localUnit.ownedItemId,
        editionId: localUnit.editionId,
        variantId: localUnit.variantId,
        bundleReleaseId: localUnit.bundleReleaseId,
        unitType: localUnit.unitType,
        seasonNumber: localUnit.seasonNumber,
        episodeNumber: localUnit.episodeNumber,
        completedAt: localUnit.completedAt,
        updatedAt: now,
      ));
      trackingUnitDeletes.add(localUnit);
    }

    await _catalogCache().upsertAll([item]);
    _addCatalogSnapshotChange(syncChanges, <String>{}, item, now);
    await _trackingCache().upsertAll(trackingUpserts);
    for (final deleted in trackingDeletes) {
      await _trackingCache().markDeleted(deleted, now);
    }
    await _wishlistCache().upsertAll(wishlistUpserts);
    await _wishlistCache().markDeletedAll(wishlistDeletes, now);
    await _trackingUnitsCache().upsertAll(trackingUnitUpserts);
    for (final deleted in trackingUnitDeletes) {
      await _trackingUnitsCache().markDeleted(deleted, now);
    }
    await _syncQueue().enqueueAll(syncChanges);
    if (notify) {
      await _notifyCollectionChanged(
          wishlistChanged: localWishlistItems.isNotEmpty);
    }
    return localTrackingEntries.length +
        localWishlistItems.length +
        localTrackingUnits.length;
  }

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
  }) async {
    final now = DateTime.now().toUtc();
    final normalizedAnchorType = _normalizedPersonalAnchorType(
      anchorType ?? item.anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      fallbackEditionId: item.editionId,
      fallbackVariantId: item.variantId,
      fallbackBundleReleaseId: item.bundleReleaseId,
    );
    final updated = WishlistItem(
      id: item.id,
      itemId: item.itemId,
      catalogRef: item.catalogRef,
      anchorType: normalizedAnchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      targetPriceCents: targetPriceCents,
      currency: currency,
      notes: notes,
      createdAt: item.createdAt,
      updatedAt: now,
      deletedAt: item.deletedAt,
    );
    await _wishlistCache().upsert(updated);
    await _enqueueWishlistItem(updated, 'upsert', now);
    await _enqueueCatalogSnapshotForItemId(item.itemId, now);
    if (notify) {
      await _notifyWishlistChanged();
    }
    return updated;
  }

  Future<void> removeFromWishlist(
    String itemId, {
    String? wishlistItemId,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await _wishlistItemsForMutation(
      itemId,
      wishlistItemId: wishlistItemId,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    for (final item in existing) {
      await _wishlistCache().markDeleted(item, now);
      await _enqueueWishlistItem(
        item.copyWith(updatedAt: now, deletedAt: now),
        'delete',
        now,
      );
    }
    if (notify) {
      await _notifyWishlistChanged();
    }
  }

  Future<void> toggleWishlist(
    String itemId, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) async {
    final existing = await _wishlistCache().findActiveByItemAnchor(
      itemId,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (existing == null) {
      await addToWishlist(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    } else {
      await removeFromWishlist(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    }
  }

  Future<int> importRows(List<CollectionCsvRow> rows) async {
    if (rows.isEmpty) {
      return 0;
    }
    final preview = await previewImportRows(rows);
    final resolvedRows = [...preview.resolvedRows, ...preview.conflictRows];
    if (resolvedRows.isEmpty) {
      return 0;
    }
    final db = ref.read(localDatabaseProvider);
    final ownedCache = _ownedCache();
    final trackingCache = _trackingCache();
    final wishlistCache = _wishlistCache();
    final catalogCache = _catalogCache();
    final syncQueue = _syncQueue();
    final catalogItems = await catalogCache.findByIds(resolvedRows.map(
      (row) => row.itemId,
    ));
    final importedCatalogItems = <CatalogItem>[];
    for (final row in resolvedRows) {
      final snapshot = _catalogItemFromCsvRow(
        row,
        existing: catalogItems[row.itemId],
      );
      if (snapshot != null) {
        catalogItems[row.itemId] = snapshot;
        importedCatalogItems.add(snapshot);
      }
    }
    final now = DateTime.now().toUtc();
    final existingWishlist = {
      for (final item in await wishlistCache.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        item.itemId: item,
    };
    final existingOwned = {
      for (final item in await ownedCache.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        item.itemId: item,
    };
    final existingTrackingByOwnedItemId = {
      for (final entry in await trackingCache.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        if (entry.ownedItemId != null) entry.ownedItemId!: entry,
    };
    final activeWishlistItemIds = existingWishlist.keys.toSet();
    final ownedItems = <OwnedItem>[];
    final trackingUpserts = <TrackingEntry>[];
    final trackingDeletes = <TrackingEntry>[];
    final wishlistDeletes = <WishlistItem>[];
    final wishlistUpserts = <WishlistItem>[];
    final syncChanges = <SyncChange>[];
    final snapshotItemIds = <String>{};
    var imported = 0;

    for (final row in resolvedRows) {
      if (!row.isOwned && !row.isWishlisted) {
        continue;
      }
      imported++;
      _addCatalogSnapshotChange(
        syncChanges,
        snapshotItemIds,
        catalogItems[row.itemId],
        now,
      );
      final existingWishlistItem = existingWishlist[row.itemId];
      if (row.isOwned) {
        final ownedItem = _ownedItemFromCsvRow(
          row,
          now,
          existing: existingOwned[row.itemId],
        );
        ownedItems.add(ownedItem);
        syncChanges.add(_syncChangeForOwnedItem(ownedItem, 'upsert', now));
        final trackingEntry = _trackingEntryFromOwnedItem(ownedItem, now);
        final existingTracking = existingTrackingByOwnedItemId[ownedItem.id];
        if (trackingEntry != null) {
          trackingUpserts.add(trackingEntry);
          syncChanges.add(
            _syncChangeForTrackingEntry(trackingEntry, 'upsert', now),
          );
        } else if (existingTracking != null) {
          final deleted = _trackingDeletion(existingTracking, now);
          trackingDeletes.add(deleted);
          syncChanges.add(_syncChangeForTrackingEntry(deleted, 'delete', now));
        }
        if (existingWishlistItem != null &&
            activeWishlistItemIds.contains(row.itemId)) {
          final deleted = existingWishlistItem.copyWith(
            updatedAt: now,
            deletedAt: now,
          );
          wishlistDeletes.add(deleted);
          syncChanges.add(_syncChangeForWishlistItem(deleted, 'delete', now));
          activeWishlistItemIds.remove(row.itemId);
        }
      }
      if (row.isWishlisted && !activeWishlistItemIds.contains(row.itemId)) {
        final wishlistItem = WishlistItem(
          id: _uuid.v4(),

          catalogRef: _catalogRefForItem(
            row.itemId,
            catalogItems[row.itemId],
          ),
          anchorType: PersonalItemAnchorType.item.apiValue,
          createdAt: now,
          updatedAt: now,
        );
        wishlistUpserts.add(wishlistItem);
        syncChanges
            .add(_syncChangeForWishlistItem(wishlistItem, 'upsert', now));
        activeWishlistItemIds.add(row.itemId);
      }
    }

    if (imported == 0) {
      return 0;
    }
    await db.transaction(() async {
      await catalogCache.upsertAll(importedCatalogItems);
      await ownedCache.upsertAll(ownedItems);
      await trackingCache.upsertAll(trackingUpserts);
      for (final entry in trackingDeletes) {
        await trackingCache.markDeleted(entry, now);
      }
      await wishlistCache.markDeletedAll(wishlistDeletes, now);
      await wishlistCache.upsertAll(wishlistUpserts);
      await syncQueue.enqueueAll(syncChanges);
    });

    // Save imported custom field values.
    final cfRepo = CustomFieldRepository(db);
    final cfDefs = await cfRepo.listDefinitions();
    final defsByName = {
      for (final def in cfDefs) def.name.toLowerCase(): def,
    };
    final ownedIdByItemId = {
      for (final o in ownedItems) o.itemId: o.id,
    };
    final cfValuesToSave = <CustomFieldValue>[];
    for (final row in resolvedRows) {
      if (row.customFieldValues.isEmpty || !row.isOwned) continue;
      final ownedId = ownedIdByItemId[row.itemId];
      if (ownedId == null) continue;
      for (final entry in row.customFieldValues.entries) {
        final def = defsByName[entry.key.toLowerCase()];
        if (def == null || entry.value == null) continue;
        cfValuesToSave.add(CustomFieldValue(
          id: _uuid.v4(),
          targetId: ownedId,
          targetScope: CustomFieldTargetScope.ownedCopy,
          catalogRef: _catalogRefForItem(
            row.itemId,
            catalogItems[row.itemId],
          ),
          fieldDefinitionId: def.id,
          value: entry.value,
          updatedAt: now,
        ));
      }
    }
    if (cfValuesToSave.isNotEmpty) {
      await cfRepo.upsertValues(cfValuesToSave);
    }

    await _notifyCollectionChanged(wishlistChanged: true);
    return imported;
  }

  Future<CollectionImportPreview> previewImportRows(
    List<CollectionCsvRow> rows,
  ) async {
    final catalog = _catalogCache();
    final resolved = <CollectionCsvRow>[];
    final conflicts = <CollectionCsvRow>[];
    final unresolved = <CollectionCsvRow>[];
    final skipped = <CollectionCsvRow>[];
    final duplicates = <CollectionCsvRow>[];
    final seenItemIds = <String>{};
    final ownedCache = _ownedCache();
    for (final row in rows) {
      if (!row.isOwned && !row.isWishlisted) {
        skipped.add(row);
        continue;
      }
      final resolvedRow = await _resolveCsvRow(row, catalog);
      if (resolvedRow != null) {
        if (!seenItemIds.add(resolvedRow.itemId)) {
          duplicates.add(resolvedRow);
          continue;
        }
        final existingOwned =
            await ownedCache.findActiveByItemIds([resolvedRow.itemId]);
        if (resolvedRow.isOwned && existingOwned.isNotEmpty) {
          conflicts.add(resolvedRow);
        } else {
          resolved.add(resolvedRow);
        }
      } else {
        unresolved.add(row);
      }
    }
    return CollectionImportPreview(
      totalRows: rows.length,
      resolvedRows: resolved,
      conflictRows: conflicts,
      unresolvedRows: unresolved,
      skippedRows: skipped,
      duplicateRows: duplicates,
    );
  }

  Future<CollectionCsvRow?> _resolveCsvRow(
    CollectionCsvRow row,
    CatalogCacheRepository catalog,
  ) async {
    if (row.itemId.trim().isNotEmpty) {
      return row;
    }
    final matched = await _matchCsvRowToCatalog(row, catalog);
    return matched == null ? null : row.copyWith(itemId: matched.id);
  }

  Future<CatalogItem?> _matchCsvRowToCatalog(
    CollectionCsvRow row,
    CatalogCacheRepository catalog,
  ) async {
    final barcode = row.barcode?.trim();
    if (barcode != null && barcode.isNotEmpty) {
      final match = await catalog.findByBarcode(barcode, kind: row.kind);
      if (match != null) {
        return match;
      }
    }
    final title = row.title?.trim();
    if (title == null || title.isEmpty) {
      return null;
    }
    return catalog.findByTitleAndIssue(
      title: title,
      itemNumber: row.itemNumber,
      kind: row.kind,
    );
  }

  OwnedItem _ownedItemFromCsvRow(
    CollectionCsvRow row,
    DateTime now, {
    OwnedItem? existing,
  }) {
    final hasLocationId = row.locationId?.trim().isNotEmpty ?? false;
    return OwnedItem(
      id: existing?.id ?? _uuid.v4(),

      catalogRef: existing?.catalogRef ??
          CatalogEntityRef(
            kind: 'unknown',
            entityType: CatalogEntityType.work,
            id: row.itemId,
          ),
      isDigital: _csvOwnedItemIsDigital(row, existing: existing),
      anchorType: existing?.anchorType,
      editionId: existing?.editionId,
      variantId: existing?.variantId,
      bundleReleaseId: existing?.bundleReleaseId,
      condition: row.condition ?? existing?.condition,
      grade: row.grade ?? existing?.grade,
      purchaseDate: row.purchaseDate ?? existing?.purchaseDate,
      pricePaidCents: row.pricePaidCents ?? existing?.pricePaidCents,
      currency: row.currency ?? existing?.currency,
      personalNotes: row.notes ?? existing?.personalNotes,
      quantity: row.quantity ?? existing?.quantity ?? 1,
      locationId: hasLocationId ? row.locationId : existing?.locationId,
      indexNumber: row.indexNumber ?? existing?.indexNumber,
      coverPriceCents: row.coverPriceCents ?? existing?.coverPriceCents,
      rawOrSlabbed: row.rawOrSlabbed ?? existing?.rawOrSlabbed,
      gradingCompany: row.gradingCompany ?? existing?.gradingCompany,
      graderNotes: row.graderNotes ?? existing?.graderNotes,
      signedBy: row.signedBy ?? existing?.signedBy,
      labelType: row.labelType ?? existing?.labelType,
      certificationNumber:
          row.certificationNumber ?? existing?.certificationNumber,
      keyComic: row.keyComic || (existing?.keyComic ?? false),
      keyReason: row.keyReason ?? existing?.keyReason,
      rating: row.rating ?? existing?.rating,
      readStatus: row.readStatus ?? existing?.readStatus,
      startedAt: row.startedAt ?? existing?.startedAt,
      finishedAt: row.finishedAt ?? existing?.finishedAt,
      tags: row.tags ?? existing?.tags,
      updatedAt: now,
      deletedAt: existing?.deletedAt,
      soldAt: row.soldAt ?? existing?.soldAt,
      sellPriceCents: row.sellPriceCents ?? existing?.sellPriceCents,
      soldTo: row.soldTo ?? existing?.soldTo,
    );
  }

  CatalogEntityRef _catalogRefForItem(
    String itemId,
    CatalogItem? item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    if (item == null) {
      return CatalogEntityRef(
        kind: 'unknown',
        entityType: CatalogEntityType.unknown,
        id: itemId,
      );
    }
    final resolvedAnchorType = resolvePersonalItemAnchorType(
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    final entityType = switch (resolvedAnchorType) {
      'edition' => CatalogEntityType.edition,
      'variant' || 'bundle_release' => CatalogEntityType.release,
      _ => CatalogEntityType.work,
    };
    return CatalogEntityRef(
      kind: item.kind,
      entityType: entityType,
      id: item.id.isNotEmpty ? item.id : itemId,
    );
  }

  CatalogEntityRef _trackingCatalogRefForItemId(
    String itemId, {
    String? sourceType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    int? seasonNumber,
    int? episodeNumber,
  }) {
    final anchorType = _normalizedPersonalAnchorType(
      sourceType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      fallbackEditionId: editionId,
      fallbackVariantId: variantId,
      fallbackBundleReleaseId: bundleReleaseId,
    );
    final entityType = (seasonNumber != null || episodeNumber != null)
        ? CatalogEntityType.episode
        : switch (anchorType) {
            'edition' => CatalogEntityType.edition,
            'variant' || 'bundle_release' => CatalogEntityType.release,
            _ => CatalogEntityType.work,
          };
    return CatalogEntityRef(
      kind: 'unknown',
      entityType: entityType,
      id: itemId,
    );
  }

  CatalogItem? _catalogItemFromCsvRow(
    CollectionCsvRow row, {
    CatalogItem? existing,
  }) {
    final itemId = row.itemId.trim();
    if (itemId.isEmpty) {
      return null;
    }
    final kind = _firstText(row.kind, existing?.kind)?.toLowerCase();
    final title = _firstText(row.title, existing?.title);
    if (kind == null || title == null) {
      return existing;
    }
    return CatalogItem(
      id: itemId,
      kind: kind,
      title: title,
      itemNumber: _firstText(row.itemNumber, existing?.itemNumber),
      synopsis: existing?.synopsis,
      coverImageUrl: existing?.coverImageUrl,
      thumbnailImageUrl: existing?.thumbnailImageUrl,
      editionTitle: _firstText(row.editionTitle, existing?.editionTitle),
      physicalFormat: _firstText(row.physicalFormat, existing?.physicalFormat),
      physicalFormatLabel:
          _firstText(row.physicalFormatLabel, existing?.physicalFormatLabel),
      publisher: _firstText(row.publisher, existing?.publisher),
      releaseDate: row.releaseDate ?? existing?.releaseDate,
      releaseYear: row.releaseDate?.year ?? existing?.releaseYear,
      barcode: _firstText(row.barcode, existing?.barcode),
      variant: _firstText(row.variant, existing?.variant),
    );
  }

  String? _firstText(String? preferred, String? fallback) {
    final trimmed = preferred?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    final fallbackTrimmed = fallback?.trim();
    return fallbackTrimmed == null || fallbackTrimmed.isEmpty
        ? null
        : fallbackTrimmed;
  }

  SyncChange _syncChangeForOwnedItem(
    OwnedItem item,
    String action,
    DateTime changedAt,
  ) {
    return SyncChange(
      id: _uuid.v4(),
      entityType: 'owned_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: changedAt,
    );
  }

  SyncChange _syncChangeForWishlistItem(
    WishlistItem item,
    String action,
    DateTime changedAt,
  ) {
    return SyncChange(
      id: _uuid.v4(),
      entityType: 'wishlist_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: changedAt,
    );
  }

  SyncChange _syncChangeForTrackingEntry(
    TrackingEntry item,
    String action,
    DateTime changedAt,
  ) {
    return SyncChange(
      id: _uuid.v4(),
      entityType: 'tracking_entry',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: changedAt,
    );
  }

  SyncChange _syncChangeForCatalogItem(CatalogItem item, DateTime changedAt) {
    return SyncChange(
      id: _uuid.v4(),
      entityType: 'library_item_snapshot',
      entityId: item.id,
      action: 'upsert',
      payload: item.toSyncPayload(),
      clientChangedAt: changedAt,
    );
  }

  void _addCatalogSnapshotChange(
    List<SyncChange> changes,
    Set<String> snapshotItemIds,
    CatalogItem? item,
    DateTime changedAt,
  ) {
    if (item == null || !snapshotItemIds.add(item.id)) {
      return;
    }
    changes.add(_syncChangeForCatalogItem(item, changedAt));
  }

  Future<void> _notifyCollectionChanged({bool wishlistChanged = false}) async {
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
    ref.invalidate(collectionProvider);
    ref.invalidate(trackingEntriesProvider);
    ref.invalidate(trackingEntriesByCatalogItemProvider);
    ref.invalidate(trackingUnitsProvider);
    ref.invalidate(trackingUnitsByCatalogItemProvider);
    if (wishlistChanged) {
      ref.invalidate(wishlistIdsProvider);
      ref.invalidate(wishlistProvider);
    }
    ref.invalidate(shelfProvider);
    unawaited(
        ref.read(syncControllerProvider.notifier).syncOnlineFirstIfEnabled());
  }

  Future<void> _notifyWishlistChanged() async {
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
    ref.invalidate(wishlistIdsProvider);
    ref.invalidate(wishlistProvider);
    ref.invalidate(shelfProvider);
    unawaited(
        ref.read(syncControllerProvider.notifier).syncOnlineFirstIfEnabled());
  }

  OwnedItemsCacheRepository _ownedCache() {
    return OwnedItemsCacheRepository(ref.read(localDatabaseProvider));
  }

  WishlistItemsCacheRepository _wishlistCache() {
    return WishlistItemsCacheRepository(ref.read(localDatabaseProvider));
  }

  CatalogCacheRepository _catalogCache() {
    return CatalogCacheRepository(ref.read(localDatabaseProvider));
  }

  TrackingEntriesCacheRepository _trackingCache() {
    return TrackingEntriesCacheRepository(ref.read(localDatabaseProvider));
  }

  TrackingUnitsCacheRepository _trackingUnitsCache() {
    return TrackingUnitsCacheRepository(ref.read(localDatabaseProvider));
  }

  WatchSessionsCacheRepository _watchSessionsCache() {
    return WatchSessionsCacheRepository(ref.read(localDatabaseProvider));
  }

  UserMetadataOverridesCacheRepository _overridesCache() {
    return UserMetadataOverridesCacheRepository(
        ref.read(localDatabaseProvider));
  }

  CustomEpisodesCacheRepository _customEpisodesCache() {
    return CustomEpisodesCacheRepository(ref.read(localDatabaseProvider));
  }

  SyncQueueRepository _syncQueue() {
    return SyncQueueRepository(ref.read(localDatabaseProvider));
  }

  Future<void> _enqueueOwnedItem(
      OwnedItem item, String action, DateTime changedAt) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'owned_item',
        entityId: item.id,
        action: action,
        payload: item.toSyncPayload(),
        clientChangedAt: changedAt,
      ),
    );
  }

  Future<void> _enqueueWishlistItem(
      WishlistItem item, String action, DateTime changedAt) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'wishlist_item',
        entityId: item.id,
        action: action,
        payload: item.toSyncPayload(),
        clientChangedAt: changedAt,
      ),
    );
  }

  Future<void> _enqueueTrackingEntry(
    TrackingEntry item,
    String action,
    DateTime changedAt,
  ) {
    return _syncQueue().enqueue(
      _syncChangeForTrackingEntry(item, action, changedAt),
    );
  }

  Future<void> _enqueueWatchSession(
    WatchSession session,
    String action,
    DateTime changedAt,
  ) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'watch_session',
        entityId: session.id,
        action: action,
        payload: session.toSyncPayload(),
        clientChangedAt: changedAt,
      ),
    );
  }

  Future<void> _enqueueMetadataOverride(
    UserMetadataOverride override,
    String action,
    DateTime changedAt,
  ) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'metadata_override',
        entityId: override.id,
        action: action,
        payload: override.toSyncPayload(),
        clientChangedAt: changedAt,
      ),
    );
  }

  Future<void> _enqueueCustomEpisode(
    CustomEpisode episode,
    String action,
    DateTime changedAt,
  ) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'custom_episode',
        entityId: episode.id,
        action: action,
        payload: episode.toSyncPayload(),
        clientChangedAt: changedAt,
      ),
    );
  }

  Future<void> _enqueueCatalogSnapshotForItemId(
    String itemId,
    DateTime changedAt,
  ) async {
    final item = await _catalogCache().findById(
      itemId,
    );
    if (item == null) {
      return;
    }
    await _syncQueue().enqueue(_syncChangeForCatalogItem(item, changedAt));
  }

  /// Fire-and-forget download of the cover image for a newly added item.
  Future<void> _downloadCoverForOwnedItem(
      String ownedItemId, String itemId) async {
    if (!_pendingCoverDownloads.add(ownedItemId)) {
      return;
    }
    try {
      final imagesCache = _imagesCache();
      // Skip if image already cached locally.
      final cached = await imagesCache.frontCoverBytes(ownedItemId);
      if (cached != null) return;

      final item = await _catalogCache().findById(itemId);
      final coverImageUrl = item?.displayCoverUrl;
      if (coverImageUrl == null || coverImageUrl.isEmpty) return;

      final service = ImageDownloadService(imagesRepo: imagesCache);
      for (var attempt = 0; attempt < 3; attempt++) {
        final downloaded = await service.downloadAndStoreCover(
          ownedItemId: ownedItemId,
          coverImageUrl: coverImageUrl,
        );
        if (downloaded != null) {
          return;
        }
      }
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'collection',
        message:
            'Best-effort background cover download failed for owned item $ownedItemId.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _pendingCoverDownloads.remove(ownedItemId);
    }
  }

  ItemImagesCacheRepository _imagesCache() =>
      ItemImagesCacheRepository(ref.read(localDatabaseProvider));

  Future<void> _syncTrackingForOwnedItem(
    OwnedItem ownedItem,
    DateTime changedAt,
  ) async {
    final entry = _trackingEntryFromOwnedItem(ownedItem, changedAt);
    final existing = await _trackingCache().findById(
      _trackingEntryIdForOwnedItem(ownedItem.id),
    );
    if (entry == null) {
      if (existing != null && !existing.isDeleted) {
        final deleted = _trackingDeletion(existing, changedAt);
        await _trackingCache().markDeleted(existing, changedAt);
        await _enqueueTrackingEntry(deleted, 'delete', changedAt);
      }
      return;
    }
    await _trackingCache().upsert(entry);
    await _enqueueTrackingEntry(entry, 'upsert', changedAt);
  }

  Future<void> _syncTrackingEntry(
    TrackingEntry entry,
    DateTime changedAt, {
    bool allowEmpty = false,
  }) async {
    final existing = await _trackingCache().findById(entry.id);
    if (!_hasTrackingData(entry) && !allowEmpty) {
      if (existing != null && !existing.isDeleted) {
        final deleted = _trackingDeletion(existing, changedAt);
        await _trackingCache().markDeleted(existing, changedAt);
        await _enqueueTrackingEntry(deleted, 'delete', changedAt);
      }
      return;
    }
    await _trackingCache().upsert(entry);
    await _enqueueTrackingEntry(entry, 'upsert', changedAt);
  }

  TrackingEntry? _trackingEntryFromOwnedItem(
    OwnedItem ownedItem,
    DateTime changedAt,
  ) {
    final normalizedStatus = _normalizeTrackingValue(ownedItem.readStatus);
    if (normalizedStatus == null &&
        ownedItem.rating == null &&
        ownedItem.startedAt == null &&
        ownedItem.finishedAt == null) {
      return null;
    }
    return TrackingEntry(
      id: _trackingEntryIdForOwnedItem(ownedItem.id),
      itemId: ownedItem.itemId,
      catalogRef: ownedItem.catalogRef,
      ownedItemId: ownedItem.id,
      editionId: ownedItem.editionId,
      variantId: ownedItem.variantId,
      sourceType: ownedItem.isDigital == true
          ? TrackingSourceType.digital
          : TrackingSourceType.physical,
      status: normalizedStatus,
      rating: ownedItem.rating,
      startedAt: ownedItem.startedAt,
      finishedAt: ownedItem.finishedAt,
      updatedAt: changedAt,
    );
  }

  TrackingEntry _trackingDeletion(TrackingEntry entry, DateTime changedAt) {
    return TrackingEntry(
      id: entry.id,
      itemId: entry.itemId,
      catalogRef: entry.catalogRef,
      ownedItemId: entry.ownedItemId,
      editionId: entry.editionId,
      variantId: entry.variantId,
      sourceType: entry.sourceType,
      status: entry.status,
      rating: entry.rating,
      startedAt: entry.startedAt,
      finishedAt: entry.finishedAt,
      progressCurrent: entry.progressCurrent,
      progressTotal: entry.progressTotal,
      timesCompleted: entry.timesCompleted,
      notes: entry.notes,
      seasonNumber: entry.seasonNumber,
      episodeNumber: entry.episodeNumber,
      updatedAt: changedAt,
      deletedAt: changedAt,
    );
  }

  String _trackingEntryIdForOwnedItem(String ownedItemId) {
    return _uuid.v5(Namespace.url.value, 'tracking-entry:owned:$ownedItemId');
  }

  String _trackingUnitIdForEpisode(
    String itemId, {
    required int seasonNumber,
    required int episodeNumber,
  }) {
    return _uuid.v5(
      Namespace.url.value,
      'tracking-unit:episode:$itemId:$seasonNumber:$episodeNumber',
    );
  }

  Future<bool?> _resolveOwnedDigitalFlag({
    required String itemId,
  }) async {
    final catalogItem = await _catalogCache().findById(itemId);
    if (catalogItem == null) {
      return null;
    }
    return digitalPhysicalMediaFormatFlag(
      catalogItem.physicalFormat,
      label: catalogItem.physicalFormatLabel ?? catalogItem.variant,
    );
  }

  bool? _csvOwnedItemIsDigital(
    CollectionCsvRow row, {
    OwnedItem? existing,
  }) {
    if ((row.physicalFormat?.trim().isNotEmpty ?? false) ||
        (row.physicalFormatLabel?.trim().isNotEmpty ?? false)) {
      return digitalPhysicalMediaFormatFlag(
        row.physicalFormat,
        label: row.physicalFormatLabel,
      );
    }
    return existing?.isDigital;
  }

  String _trackingEntryIdForItem(String itemId, {String? sourceType}) {
    final normalizedSource = normalizeTrackingSourceType(sourceType) ??
        _normalizeTrackingValue(sourceType) ??
        'item';
    return _uuid.v5(
      Namespace.url.value,
      'tracking-entry:item:$itemId:$normalizedSource',
    );
  }

  Future<void> _reconcileTrackingEntryFromUnits(
    String itemId, {
    required DateTime changedAt,
  }) async {
    final units = await _trackingUnitsCache().findActiveByItemIds([itemId]);
    final watchedEpisodes = units
        .where(
          (unit) =>
              unit.unitType == TrackingUnitType.episode && !unit.isDeleted,
        )
        .toList(growable: false)
      ..sort((a, b) {
        final seasonCompare =
            (b.seasonNumber ?? 0).compareTo(a.seasonNumber ?? 0);
        if (seasonCompare != 0) {
          return seasonCompare;
        }
        return (b.episodeNumber ?? 0).compareTo(a.episodeNumber ?? 0);
      });
    final existingEntries =
        await _trackingCache().findActiveByItemIds([itemId]);
    final summaryEntry = _summaryTrackingEntryForItem(existingEntries);
    if (watchedEpisodes.isEmpty) {
      if (summaryEntry == null) {
        return;
      }
      await _syncTrackingEntry(
        TrackingEntry(
          id: summaryEntry.id,
          itemId: summaryEntry.itemId,
          catalogRef: summaryEntry.catalogRef,
          ownedItemId: summaryEntry.ownedItemId,
          editionId: summaryEntry.editionId,
          variantId: summaryEntry.variantId,
          bundleReleaseId: summaryEntry.bundleReleaseId,
          sourceType: summaryEntry.sourceType,
          status: summaryEntry.status,
          rating: summaryEntry.rating,
          startedAt: summaryEntry.startedAt,
          finishedAt: summaryEntry.finishedAt,
          progressCurrent: null,
          progressTotal: null,
          timesCompleted: summaryEntry.timesCompleted,
          notes: summaryEntry.notes,
          seasonNumber: null,
          episodeNumber: null,
          updatedAt: changedAt,
        ),
        changedAt,
        allowEmpty: true,
      );
      return;
    }
    final latestEpisode = watchedEpisodes.first;
    final normalizedSourceType =
        summaryEntry?.sourceType ?? TrackingSourceType.digital;
    await _syncTrackingEntry(
      TrackingEntry(
        id: summaryEntry?.id ??
            _trackingEntryIdForItem(
              itemId,
              sourceType: trackingSourceTypeApiValue(normalizedSourceType),
            ),
        itemId: itemId,
        catalogRef: _trackingCatalogRefForItemId(
          itemId,
          sourceType: trackingSourceTypeApiValue(normalizedSourceType),
          editionId: summaryEntry?.editionId,
          variantId: summaryEntry?.variantId,
          bundleReleaseId: summaryEntry?.bundleReleaseId,
          seasonNumber: latestEpisode.seasonNumber,
          episodeNumber: latestEpisode.episodeNumber,
        ),
        ownedItemId: summaryEntry?.ownedItemId,
        editionId: summaryEntry?.editionId,
        variantId: summaryEntry?.variantId,
        bundleReleaseId: summaryEntry?.bundleReleaseId,
        sourceType: normalizedSourceType,
        status: summaryEntry?.status,
        rating: summaryEntry?.rating,
        startedAt: summaryEntry?.startedAt,
        finishedAt: summaryEntry?.finishedAt,
        progressCurrent: watchedEpisodes.length,
        progressTotal: null,
        timesCompleted: summaryEntry?.timesCompleted,
        notes: summaryEntry?.notes,
        seasonNumber: latestEpisode.seasonNumber,
        episodeNumber: latestEpisode.episodeNumber,
        updatedAt: changedAt,
      ),
      changedAt,
      allowEmpty: true,
    );
  }

  TrackingEntry? _summaryTrackingEntryForItem(List<TrackingEntry> entries) {
    TrackingEntry? fallback;
    for (final entry in entries) {
      if (entry.ownedItemId == null) {
        return entry;
      }
      fallback ??= entry;
    }
    return fallback;
  }

  String? _normalizeTrackingValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _normalizeTrackingSourceTypeValue(Object? value) {
    return trackingSourceTypeApiValue(value) ??
        (value is String? ? normalizeTrackingSourceType(value) : null);
  }

  String? _normalizeTrackingStatusValue(Object? value) {
    final normalizedStatus = mediaTrackingStatusFromValue(value);
    if (normalizedStatus != null) {
      return mediaTrackingStatusToStorageValue(normalizedStatus);
    }
    return value is String? ? _normalizeTrackingValue(value) : null;
  }

  String? _normalizedPersonalAnchorType(
    String? anchorType, {
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    String? fallbackEditionId,
    String? fallbackVariantId,
    String? fallbackBundleReleaseId,
  }) {
    return resolvePersonalItemAnchorType(
          anchorType: anchorType,
          editionId: editionId ?? fallbackEditionId,
          variantId: variantId ?? fallbackVariantId,
          bundleReleaseId: bundleReleaseId ?? fallbackBundleReleaseId,
        ) ??
        PersonalItemAnchorType.item.apiValue;
  }

  bool _hasTrackingData(TrackingEntry entry) {
    return entry.statusStorageValue != null ||
        entry.rating != null ||
        entry.startedAt != null ||
        entry.finishedAt != null ||
        entry.progressCurrent != null ||
        entry.progressTotal != null ||
        entry.timesCompleted != null ||
        _normalizeTrackingValue(entry.notes) != null ||
        entry.seasonNumber != null ||
        entry.episodeNumber != null;
  }

  TrackingEntry _mergeTrackingEntryForPromotion(
    TrackingEntry target,
    TrackingEntry local, {
    required String itemId,
    required DateTime changedAt,
  }) {
    return target.copyWith(
      itemId: itemId,
      status: local.status ?? target.status,
      rating: local.rating ?? target.rating,
      startedAt: local.startedAt ?? target.startedAt,
      finishedAt: local.finishedAt ?? target.finishedAt,
      progressCurrent: local.progressCurrent ?? target.progressCurrent,
      progressTotal: local.progressTotal ?? target.progressTotal,
      timesCompleted: local.timesCompleted ?? target.timesCompleted,
      notes: local.notes ?? target.notes,
      seasonNumber: local.seasonNumber ?? target.seasonNumber,
      episodeNumber: local.episodeNumber ?? target.episodeNumber,
      episodeRatings: {
        ...target.episodeRatings,
        ...local.episodeRatings,
      },
      updatedAt: changedAt,
      deletedAt: null,
    );
  }

  WishlistItem _mergeWishlistItemForPromotion(
    WishlistItem target,
    WishlistItem local, {
    required String itemId,
    required DateTime changedAt,
  }) {
    return target.copyWith(
      itemId: itemId,
      anchor: local.anchor ?? target.anchor,
      targetPriceCents: local.targetPriceCents ?? target.targetPriceCents,
      currency: local.currency ?? target.currency,
      notes: local.notes ?? target.notes,
      updatedAt: changedAt,
      deletedAt: null,
    );
  }

  WishlistItem? _findMatchingWishlistItem(
    Iterable<WishlistItem> items,
    WishlistItem candidate,
  ) {
    for (final item in items) {
      if (_wishlistAnchorsMatch(
        item,
        anchorType: candidate.anchorType,
        editionId: candidate.editionId,
        variantId: candidate.variantId,
        bundleReleaseId: candidate.bundleReleaseId,
      )) {
        return item;
      }
    }
    return null;
  }

  Future<List<WishlistItem>> _wishlistItemsForMutation(
    String itemId, {
    String? wishlistItemId,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) async {
    if (wishlistItemId != null && wishlistItemId.trim().isNotEmpty) {
      final item = await _wishlistCache().findById(wishlistItemId);
      if (item == null || item.isDeleted || item.itemId != itemId) {
        return const <WishlistItem>[];
      }
      return [item];
    }
    final hasAnchor = _wishlistAnchorsRequested(
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (hasAnchor) {
      final item = await _wishlistCache().findActiveByItemAnchor(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
      return item == null ? const <WishlistItem>[] : [item];
    }
    return _wishlistCache().listActiveByItemId(itemId);
  }

  bool _wishlistAnchorsRequested({
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    return PersonalItemAnchor.fromRaw(
          anchorType: anchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
        ) !=
        null;
  }

  bool _wishlistAnchorsMatch(
    WishlistItem item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final itemAnchor = item.anchor;
    final candidateAnchor = PersonalItemAnchor.fromRaw(
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (itemAnchor == null || candidateAnchor == null) {
      return itemAnchor == null && candidateAnchor == null;
    }
    return itemAnchor.apiValue == candidateAnchor.apiValue &&
        itemAnchor.editionId == candidateAnchor.editionId &&
        itemAnchor.variantId == candidateAnchor.variantId &&
        itemAnchor.bundleReleaseId == candidateAnchor.bundleReleaseId;
  }
}

class CollectionImportPreview {
  const CollectionImportPreview({
    required this.totalRows,
    required this.resolvedRows,
    this.conflictRows = const [],
    required this.unresolvedRows,
    required this.skippedRows,
    this.duplicateRows = const [],
  });

  final int totalRows;
  final List<CollectionCsvRow> resolvedRows;
  final List<CollectionCsvRow> conflictRows;
  final List<CollectionCsvRow> unresolvedRows;
  final List<CollectionCsvRow> skippedRows;
  final List<CollectionCsvRow> duplicateRows;

  int get resolvedCount => resolvedRows.length;
  int get conflictCount => conflictRows.length;
  int get unresolvedCount => unresolvedRows.length;
  int get skippedCount => skippedRows.length;
  int get duplicateCount => duplicateRows.length;
  int get reviewCount => conflictCount + unresolvedCount + duplicateCount;
  bool get hasImportableRows => resolvedRows.isNotEmpty;
}

final collectionMutationsProvider = Provider<CollectionMutations>((ref) {
  return CollectionMutations(ref);
});

