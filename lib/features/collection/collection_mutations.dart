import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
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
import 'package:collectarr_app/features/sync/state/sync_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

part 'collection_mutations_tracking.dart';
part 'collection_mutations_wishlist.dart';
part 'collection_mutations_import.dart';

const Object _updateItemUnset = Object();

class CollectionMutations {
  CollectionMutations(this.ref);

  final Ref ref;
  final Uuid _uuid = const Uuid();
  final Set<String> _pendingCoverDownloads = <String>{};

  LocalDatabase get _db => ref.read(localDatabaseProvider);

  /// Executes DB mutations and outbox enqueues atomically within a database transaction.
  Future<T> _runAtomicMutation<T>(Future<T> Function() action) {
    return _db.transaction(() async {
      return await action();
    });
  }

  Future<OwnedItem> addOwnedItem(
    AddOwnedItemCommand command, {
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final common = command.common;
    final catalogRef = command.catalogRef;
    final auth = ref.read(authControllerProvider);

    final ({OwnedItem ownedItem, bool wishlistChanged}) result =
        await _runAtomicMutation(() async {
      // Ensure catalog snapshot exists locally.
      final existingCatalog = await _catalogCache().findById(catalogRef.id);
      if (existingCatalog == null) {
        await _catalogCache().upsertAll([
          CatalogItem(
            id: catalogRef.id,
            kind: catalogRef.kind,
            title: catalogRef.id,
          ),
        ]);
      }

      final resolvedIsDigital =
          common.isDigital ?? await _resolveOwnedDigitalFlag(itemId: catalogRef.id);
      final normalizedAnchorType = _normalizedPersonalAnchorType(
        null,
        editionId: common.editionId,
        variantId: common.variantId,
        bundleReleaseId: common.bundleReleaseId,
      );
      final resolvedCatalogRef = _catalogRefForItem(
        catalogRef.id,
        existingCatalog,
        fallbackKind: catalogRef.kind,
        anchorType: normalizedAnchorType,
        editionId: common.editionId,
        variantId: common.variantId,
        bundleReleaseId: common.bundleReleaseId,
      );

      final ownedItem = OwnedItem(
        id: _uuid.v4(),
        catalogRef: resolvedCatalogRef,
        createdAt: now,
        isDigital: resolvedIsDigital,
        anchorType: normalizedAnchorType,
        editionId: common.editionId,
        variantId: common.variantId,
        bundleReleaseId: common.bundleReleaseId,
        details: command.details.toDetails(),
        condition: common.condition,
        grade: common.grade,
        purchaseDate: common.purchaseDate,
        pricePaidCents: common.pricePaidCents,
        currency: common.currency,
        personalNotes: common.personalNotes,
        quantity: common.quantity,
        locationId: common.locationId,
        purchaseStore: common.purchaseStore,
        collectionStatus: common.collectionStatus,
        tags: common.tags,
        rating: common.rating,
        readStatus: common.readStatus,
        startedAt: common.startedAt,
        finishedAt: common.finishedAt,
        ownerUserId: auth.userId,
        ownerLabel: auth.email,
        updatedAt: now,
      );

      await _ownedCache().upsert(ownedItem);
      await _enqueueOwnedItem(ownedItem, 'upsert', now);
      if (syncTracking) {
        await _syncTrackingForOwnedItem(ownedItem, now);
      }
      if (existingCatalog != null) {
        await _enqueueCatalogSnapshotForItemId(catalogRef.id, now);
      }

      final wishlistItems = await _wishlistItemsForMutation(
        catalogRef.id,
        anchorType: normalizedAnchorType,
        editionId: common.editionId,
        variantId: common.variantId,
        bundleReleaseId: common.bundleReleaseId,
      );
      for (final wishlistItem in wishlistItems) {
        await _wishlistCache().markDeleted(wishlistItem, now);
        await _enqueueWishlistItem(
          wishlistItem.copyWith(updatedAt: now, deletedAt: now),
          'delete',
          now,
        );
      }

      return (ownedItem: ownedItem, wishlistChanged: wishlistItems.isNotEmpty);
    });

    unawaited(_downloadCoverForOwnedItem(result.ownedItem.id, catalogRef.id));
    if (notify) {
      await _notifyCollectionChanged(wishlistChanged: result.wishlistChanged);
    }
    return result.ownedItem;
  }

  Future<OwnedItem> updateOwnedItem(
    UpdateOwnedItemCommand command, {
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final auth = ref.read(authControllerProvider);

    final updated = await _runAtomicMutation(() async {
      final existing = await _ownedCache().findById(command.ownedItemId);
      if (existing == null) {
        throw StateError('OwnedItem not found: ${command.ownedItemId}');
      }

      final resolvedDetails = command.details.when(
        unchanged: () => existing.typedDetails,
        set: (draft) => draft.toDetails(),
        clear: () => const GenericOwnedDetails(),
      );

      final updated = OwnedItem(
        id: existing.id,
        catalogRef: existing.catalogRef,
        createdAt: existing.createdAt ?? now,
        isDigital: command.isDigital.when(
          unchanged: () => existing.isDigital,
          set: (v) => v,
          clear: () => null,
        ),
        anchorType: existing.anchorType,
        editionId: existing.editionId,
        variantId: existing.variantId,
        bundleReleaseId: existing.bundleReleaseId,
        details: resolvedDetails,
        condition: command.condition.when(
          unchanged: () => existing.condition,
          set: (v) => v,
          clear: () => null,
        ),
        grade: command.grade.when(
          unchanged: () => existing.grade,
          set: (v) => v,
          clear: () => null,
        ),
        purchaseDate: command.purchaseDate.when(
          unchanged: () => existing.purchaseDate,
          set: (v) => v,
          clear: () => null,
        ),
        pricePaidCents: command.pricePaidCents.when(
          unchanged: () => existing.pricePaidCents,
          set: (v) => v,
          clear: () => null,
        ),
        currency: command.currency.when(
          unchanged: () => existing.currency,
          set: (v) => v,
          clear: () => null,
        ),
        personalNotes: command.personalNotes.when(
          unchanged: () => existing.personalNotes,
          set: (v) => v,
          clear: () => null,
        ),
        quantity: command.quantity.when(
          unchanged: () => existing.quantity,
          set: (v) => v,
          clear: () => 1,
        ),
        locationId: command.locationId.when(
          unchanged: () => existing.locationId,
          set: (v) => v,
          clear: () => null,
        ),
        purchaseStore: command.purchaseStore.when(
          unchanged: () => existing.purchaseStore,
          set: (v) => v,
          clear: () => null,
        ),
        collectionStatus: command.collectionStatus.when(
          unchanged: () => existing.collectionStatus,
          set: (v) => v,
          clear: () => null,
        ),
        tags: command.tags.when(
          unchanged: () => existing.tags,
          set: (v) => v,
          clear: () => null,
        ),
        rating: command.rating.when(
          unchanged: () => existing.rating,
          set: (v) => v,
          clear: () => null,
        ),
        readStatus: command.readStatus.when(
          unchanged: () => existing.readStatus,
          set: (v) => v,
          clear: () => null,
        ),
        startedAt: command.startedAt.when(
          unchanged: () => existing.startedAt,
          set: (v) => v,
          clear: () => null,
        ),
        finishedAt: command.finishedAt.when(
          unchanged: () => existing.finishedAt,
          set: (v) => v,
          clear: () => null,
        ),
        soldAt: command.soldAt.when(
          unchanged: () => existing.soldAt,
          set: (v) => v,
          clear: () => null,
        ),
        sellPriceCents: command.sellPriceCents.when(
          unchanged: () => existing.sellPriceCents,
          set: (v) => v,
          clear: () => null,
        ),
        soldTo: command.soldTo.when(
          unchanged: () => existing.soldTo,
          set: (v) => v,
          clear: () => null,
        ),
        marketValueCents: command.marketValueCents.when(
          unchanged: () => existing.marketValueCents,
          set: (v) => v,
          clear: () => null,
        ),
        ownerUserId: existing.ownerUserId ?? auth.userId,
        ownerLabel: existing.ownerLabel ?? auth.email,
        indexNumber: command.indexNumber.when(
          unchanged: () => existing.indexNumber,
          set: (v) => v,
          clear: () => null,
        ),
        updatedAt: now,
        deletedAt: existing.deletedAt,
      );

      await _ownedCache().upsert(updated);
      await _enqueueOwnedItem(updated, 'upsert', now);
      if (syncTracking) {
        await _syncTrackingForOwnedItem(updated, now);
      }
      return updated;
    });

    if (notify) {
      await _notifyCollectionChanged();
    }
    return updated;
  }

  Future<void> updateCatalogSnapshot(
    CatalogItem item, {
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await _runAtomicMutation(() async {
      await _catalogCache().upsertAll([item]);
      await _syncQueue().enqueue(_syncChangeForCatalogItem(item, now));
    });
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
    await _runAtomicMutation(() async {
      await _catalogCache().upsertAll(pendingItems);
      await _syncQueue().enqueueAll([
        for (final item in pendingItems) _syncChangeForCatalogItem(item, now),
      ]);
    });
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> removeItem(OwnedItem item, {bool notify = true}) async {
    final now = DateTime.now().toUtc();
    await _runAtomicMutation(() async {
      await _ownedCache().markDeleted(item, now);
      await _enqueueOwnedItem(
          item.copyWith(updatedAt: now, deletedAt: now), 'delete', now);
    });
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
    CatalogEntityRef targetRef, {
    String? id,
    String? trackingEntryId,
    int? seasonNumber,
    int? episodeNumber,
    TrackingSourceType? sourceType,
    DateTime? watchedAt,
    String? seenWhere,
    int? rating,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final session = WatchSession(
      id: id ?? _uuid.v4(),
      targetRef: targetRef,
      trackingEntryId: trackingEntryId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      sourceType: sourceType,
      watchedAt: watchedAt ?? now,
      seenWhere: seenWhere,
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
  }) async {
    final now = DateTime.now().toUtc();
    final episode = CustomEpisode(
      id: id ?? _uuid.v4(),
      seriesRef: catalogRef,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      title: title,
      overview: overview,
      airDate: airDate,
      runtimeMinutes: runtimeMinutes,
      stillImageUrl: stillImageUrl,
      localImagePath: localImagePath,
      thumbnailImageUrl: thumbnailImageUrl,
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

  CatalogEntityRef _catalogRefForItem(
    String itemId,
    CatalogItem? item, {
    String? fallbackKind,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    if (item == null) {
      return CatalogEntityRef(
        kind: fallbackKind ?? 'unknown',
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
      'season' => CatalogEntityType.season,
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

  SyncChange _syncChangeForTrackingUnit(
    TrackingUnit item,
    String action,
    DateTime changedAt,
  ) {
    return SyncChange(
      id: _uuid.v4(),
      entityType: 'tracking_unit',
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

  Future<void> _enqueueTrackingUnit(
    TrackingUnit item,
    String action,
    DateTime changedAt,
  ) {
    return _syncQueue().enqueue(
      _syncChangeForTrackingUnit(item, action, changedAt),
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

  CatalogEntityRef _episodeTrackingRef(
    CatalogEntityRef seriesRef, {
    required int seasonNumber,
    required int episodeNumber,
  }) {
    return CatalogEntityRef(
      kind: seriesRef.kind,
      entityType: CatalogEntityType.episode,
      id: _trackingUnitIdForEpisode(
        seriesRef.id,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      ),
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
