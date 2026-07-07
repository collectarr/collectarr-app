part of 'collection_mutations.dart';

extension CollectionMutationsTracking on CollectionMutations {
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
    CatalogEntityRef seriesRef, {
    required int seasonNumber,
    required int episodeNumber,
    required bool completed,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final unitId = _trackingUnitIdForEpisode(
      seriesRef.id,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );
    final episodeRef = _episodeTrackingRef(
      seriesRef,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );
    final existingUnit = await _trackingUnitsCache().findById(unitId);
    if (completed) {
      final trackingEntries =
          await _trackingCache().findActiveByItemIds([seriesRef.id]);
      final summaryEntry = _summaryTrackingEntryForItem(trackingEntries);
      final unit = TrackingUnit(
          id: unitId,
          targetRef: episodeRef,
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
        );
      await _trackingUnitsCache().upsert(unit);
      await _enqueueTrackingUnit(unit, 'upsert', now);
      // T6: Record a watch session for this episode.
      final session = WatchSession(
        id: _uuid.v4(),
        targetRef: episodeRef,
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
      await _enqueueTrackingUnit(existingUnit.copyWith(deletedAt: now, updatedAt: now), 'delete', now);
    }
    await _reconcileTrackingEntryFromUnits(seriesRef.id, changedAt: now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> setSeasonEpisodesCompleted(
    CatalogEntityRef seriesRef, {
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
          await _trackingCache().findActiveByItemIds([seriesRef.id]);
      final summaryEntry = _summaryTrackingEntryForItem(trackingEntries);
      final units = [
        for (final episodeNumber in normalizedEpisodes)
          TrackingUnit(
            id: _trackingUnitIdForEpisode(
              seriesRef.id,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
            ),
            targetRef: _episodeTrackingRef(
              seriesRef,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
            ),
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
      ];
      await _trackingUnitsCache().upsertAll(units);
      for (final unit in units) {
        await _enqueueTrackingUnit(unit, 'upsert', now);
      }
    } else {
      final deletedUnits = <TrackingUnit>[];
      for (final episodeNumber in normalizedEpisodes) {
        final unit = await _trackingUnitsCache().findById(
          _trackingUnitIdForEpisode(
            seriesRef.id,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
          ),
        );
        if (unit != null && !unit.isDeleted) {
          deletedUnits.add(unit.copyWith(deletedAt: now, updatedAt: now));
        }
      }
      await _trackingUnitsCache().markDeletedByIds(
        normalizedEpisodes.map(
          (episodeNumber) => _trackingUnitIdForEpisode(
            seriesRef.id,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
          ),
        ),
        now,
      );
      for (final unit in deletedUnits) {
        await _enqueueTrackingUnit(unit, 'delete', now);
      }
    }
    await _reconcileTrackingEntryFromUnits(seriesRef.id, changedAt: now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> addLocalOnlyTrackingEntry(
    CatalogItem item, {
    String? anchorType,
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
      catalogRef: _catalogRefForItem(item.id, item, anchorType: anchorType),
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

}
