part of '../generic_library_page.dart';

// ---------------------------------------------------------------------------
// Edit dialog launch + result persistence
// ---------------------------------------------------------------------------

typedef _PreparedPageEditTarget = ({
  LibraryProjectionItem item,
  LibraryEntrySummary? entry,
  WishlistItem? wishlist,
  TrackingSummary? activeTrackingSummary,
  CatalogSearchCandidate catalogItem,
  LibraryProjectionItem? nextItem,
  LibraryEditDialogRequest request,
});

class LibraryPageEditCoordinator {
  LibraryPageEditCoordinator(this._s);

  final GenericLibraryPageState _s;

  void showDetailPage(LibraryProjectionItem item) {
    if (_s.canOpenItemDetailDrilldown(item)) {
      _s.openItemDetailDrilldown(item);
      return;
    }
    showLibraryDetailPage(
      context: _s.context,
      request: LibraryDetailPageRequest(
        type: _s.widget.type,
        item: item,
        libraryEntrySummary: item.source.libraryEntrySummary,
        libraryEntryDispatch: item.source.libraryEntryDispatch,
        accent: _s.widget.accent,
        onAddEntry: () => _s._collectionActionCoordinator.runCollectionAction(
          (actions) => actions.addEntry(item),
        ),
        onRemoveEntry: item.source.isEntry != true
            ? null
            : () => _s._collectionActionCoordinator.confirmAndRemoveEntry(item),
        onAddWishlist: () =>
            _s._collectionActionCoordinator.runCollectionAction(
          (actions) => actions.addWishlist(item),
        ),
        onRemoveWishlist: item.source.isWishlisted
            ? () => _s._collectionActionCoordinator.runCollectionAction(
                  (actions) => actions.removeWishlist(item),
                )
            : null,
        onEdit: (_) => unawaited(showEditDialog(item, null)),
        onFilterByValue: (value) => _s._rebuild(() {
          _s._session.facets.linkedMetadataFilter =
              _s._session.facets.linkedMetadataFilter?.value == value
                  ? null
                  : LibraryLinkedMetadataFilter(value: value);
          _s._session.facets.selectedBucket = null;
          _s._session.facets.selectedLetter = null;
        }),
      ),
    );
  }

  Future<void> showEditDialog(
    LibraryProjectionItem item,
    LibraryEntrySummary? libraryEntryOverride, {
    bool openMetadataCompareOnOpen = false,
  }) async {
    if (_s._isEditDialogInFlight) {
      return;
    }
    _s._isEditDialogInFlight = true;
    final db = _s.ref.read(localDatabaseProvider);
    final catalog = _s.ref.read(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final customFieldRepo = CustomFieldRepository(db);
    final itemImageRepo = ItemImageRepository(db);
    final snapshotRepo = CatalogSnapshotRepository(db);
    final wishlistItems = _s.ref.read(wishlistProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <WishlistItem>[],
        );
    final trackingSummaries =
        _s.ref.read(trackingSummariesByLibraryEntryRefProvider);
    final shelfState = _s.ref.read(shelfProvider).asData?.value;
    final viewState =
        _s._session.preferences.viewState ?? _s._viewProfile.defaults();
    final projection = shelfState == null
        ? null
        : _s._projectionForShelf(shelfState, viewState);
    final viewItems =
        projection?.filteredItems ?? const <LibraryProjectionItem>[];
    ValueNotifier<LibraryEditDialogRequest>? requestListenable;
    var dialogClosed = false;
    var navigationLoading = false;
    late _PreparedPageEditTarget activeTarget;
    late Future<void> Function(LibraryProjectionItem target) navigateTo;

    Future<_PreparedPageEditTarget?> prepareTarget(
      LibraryProjectionItem target, {
      LibraryEntrySummary? entryOverride,
      bool compareOnOpen = false,
    }) async {
      // Edit the independent local entry, never its optional Core source.
      final targetEntryRef =
          entryOverride?.ref ?? target.target.libraryEntryRef;
      final CatalogSearchCandidate? catalogItem;
      if (targetEntryRef != null) {
        final record = await LibraryEntryStore(db).find(
          targetEntryRef.kind,
          targetEntryRef.id.value,
        );
        catalogItem = record == null || record.deletedAt != null
            ? null
            : CatalogSearchCandidate.fromLibraryEntry(
                ref: targetEntryRef,
                kindData: record.catalogData,
                primaryLabel: target.source.title,
                subtitle: target.source.catalogSummary?.subtitle,
                imageUrl: target.source.catalogSummary?.imageUrl,
              );
      } else {
        final catalogRef = target.target.catalogItemRef;
        catalogItem = catalogRef == null
            ? null
            : await snapshotRepo.findCandidateByRef(catalogRef);
      }
      if (catalogItem == null) {
        throw StateError('The selected item has no available edit snapshot.');
      }

      final entry = entryOverride ?? target.source.libraryEntrySummary;
      WishlistItem? wishlist = target.source.wishlistItem;
      final candidateCatalogRef = catalogItem.catalogRef;
      if (candidateCatalogRef != null &&
          (wishlist == null ||
              wishlist.isDeleted ||
              wishlist.catalogRef != candidateCatalogRef)) {
        wishlist = null;
        for (final candidate in wishlistItems) {
          if (!candidate.isDeleted &&
              candidate.catalogRef == candidateCatalogRef) {
            wishlist = candidate;
            break;
          }
        }
      }

      final activeTrackingSummary = resolveActiveTrackingSummary(
        libraryTrackingSummariesForItem(
          target,
          trackingSummaries,
          libraryEntry: entry,
        ),
        entry,
      );
      final currentIndex = viewItems.indexWhere(
        (candidate) => candidate.target.stableKey == target.target.stableKey,
      );
      final previousItem =
          currentIndex > 0 ? viewItems[currentIndex - 1] : null;
      final nextItem = currentIndex >= 0 && currentIndex < viewItems.length - 1
          ? viewItems[currentIndex + 1]
          : null;
      final baseRequest = LibraryEditDialogRequest(
        type: _s.widget.type,
        item: catalogItem,
        target: targetEntryRef == null
            ? target.target
            : EntryTargetRef(targetEntryRef),
        libraryEntry: entry,
        libraryEntryDispatch: target.source.libraryEntryDispatch,
        wishlistItem: wishlist,
        trackingSummary: activeTrackingSummary,
        accent: _s.widget.accent,
        physicalFormats: physicalMediaFormatsForKind(
          catalog,
          _s.widget.type.kind,
        ),
        onPrevious: previousItem == null
            ? null
            : () => unawaited(navigateTo(previousItem)),
        onNext: nextItem == null ? null : () => unawaited(navigateTo(nextItem)),
        openMetadataCompareOnOpen: compareOnOpen,
      );

      final definitionsFuture = entry == null
          ? Future.value(const <CustomFieldDefinition>[])
          : customFieldRepo.listDefinitions(
              mediaKind: _s.widget.type.kind.apiValue,
              targetScope: CustomFieldTargetScope.libraryEntry,
            );
      final customFieldScope =
          entry != null ? CustomFieldTargetScope.libraryEntry : null;
      final customFieldTargetId = entry?.ref.key;
      final customFieldValuesFuture =
          customFieldScope != null && customFieldTargetId != null
              ? customFieldRepo.listValuesForTarget(
                  targetId: customFieldTargetId,
                  targetScope: customFieldScope,
                )
              : Future.value(const <CustomFieldValue>[]);
      final imagesFuture = entry != null
          ? itemImageRepo.listForLibraryEntryRef(entry.ref)
          : Future.value(const <ItemImage>[]);
      final definitions = await definitionsFuture;
      final customFieldValues = await customFieldValuesFuture;
      final images = await imagesFuture;
      final request = baseRequest.copyWith(
        customFieldDefinitions: definitions,
        customFieldValues: customFieldValues,
        itemImages: images,
      );

      return (
        item: target,
        entry: entry,
        wishlist: wishlist,
        activeTrackingSummary: activeTrackingSummary,
        catalogItem: catalogItem,
        nextItem: nextItem,
        request: request,
      );
    }

    navigateTo = (target) async {
      if (navigationLoading || dialogClosed) return;
      navigationLoading = true;
      try {
        final prepared = await prepareTarget(target);
        if (prepared == null || dialogClosed || !_s.mounted) return;
        activeTarget = prepared;
        requestListenable?.value = prepared.request;
      } catch (error, stackTrace) {
        logRecoverableError(
          source: 'library_edit',
          message: 'Could not prepare the next editor item.',
          error: error,
          stackTrace: stackTrace,
        );
        if (!dialogClosed && _s.mounted) {
          ScaffoldMessenger.of(_s.context).showSnackBar(
            const SnackBar(content: Text('Could not load the selected item.')),
          );
        }
      } finally {
        navigationLoading = false;
      }
    };

    try {
      if (!_s.mounted) return;
      late final _PreparedPageEditTarget? initialTarget;
      try {
        initialTarget = await prepareTarget(
          item,
          entryOverride: libraryEntryOverride,
          compareOnOpen: openMetadataCompareOnOpen,
        );
      } catch (error, stackTrace) {
        logRecoverableError(
          source: 'library_edit',
          message: 'Could not prepare the selected editor item.',
          error: error,
          stackTrace: stackTrace,
        );
        if (_s.mounted) {
          ScaffoldMessenger.of(_s.context).showSnackBar(
            const SnackBar(content: Text('Could not load the selected item.')),
          );
        }
        return;
      }
      if (initialTarget == null || !_s.mounted) return;
      activeTarget = initialTarget;
      requestListenable = ValueNotifier(initialTarget.request);
      final result = await showLibraryEditDialog(
        context: _s.context,
        request: initialTarget.request,
        requestListenable: requestListenable,
        onCommit: (result) => _persistEditResult(
          result,
          target: activeTarget.item.target,
          entry: activeTarget.entry,
          wishlist: activeTarget.wishlist,
          activeTrackingSummary: activeTarget.activeTrackingSummary,
          catalogItem: activeTarget.catalogItem,
          customFieldRepo: customFieldRepo,
          itemImageRepo: itemImageRepo,
        ),
      );
      dialogClosed = true;
      if (result == null || !_s.mounted) {
        return;
      }
      if (!_s.mounted) {
        return;
      }
      _s.ref.invalidate(shelfProvider);
      _s.ref.invalidate(
        libraryCustomFieldCacheProvider(_s.widget.type.kind.apiValue),
      );
      if (result.submitAction == LibraryEditSubmitAction.saveAndNext &&
          activeTarget.nextItem != null) {
        _s._isEditDialogInFlight = false;
        unawaited(
          showEditDialog(
            activeTarget.nextItem!,
            null,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(_s.context).showSnackBar(
        SnackBar(
            content: Text('${_s.widget.type.identity.singularLabel} updated')),
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_edit',
        message: 'Could not open the item editor.',
        error: error,
        stackTrace: stackTrace,
      );
      if (_s.mounted) {
        ScaffoldMessenger.of(_s.context).showSnackBar(
          const SnackBar(content: Text('Could not open the item editor.')),
        );
      }
    } finally {
      dialogClosed = true;
      requestListenable?.dispose();
      _s._isEditDialogInFlight = false;
    }
  }

  Future<void> _persistEditResult(
    LibraryEditSelection result, {
    required LibraryTargetRef target,
    required LibraryEntrySummary? entry,
    required WishlistItem? wishlist,
    required TrackingSummary? activeTrackingSummary,
    required CatalogSearchCandidate catalogItem,
    required CustomFieldRepository customFieldRepo,
    required ItemImageRepository itemImageRepo,
  }) async {
    final now = DateTime.now();
    final coordinator = _s.ref.read(collectionCommandCoordinatorProvider);
    final wishlistMutations = _s.ref.read(wishlistMutationsProvider);
    final trackingMutations = _s.ref.read(trackingMutationsProvider);

    await _s.ref.read(collectionMutationRunnerProvider).run(action: () async {
      // Catalog data, entry personal data, attachments, custom fields, and
      // activity changes belong to one edit commit. This mutation uses the
      // same runner, so its transaction is nested into the current one.
      if (entry != null) {
        final kindData = result.kindItem.kindCapability
            .mapTransport((item) => item.kindData);
        await _s.ref.read(libraryEntryMutationsProvider).updateCatalogData(
              entry.ref,
              kindData,
            );
        await _s.ref
            .read(catalogTransportRepositoryProvider)
            .captureEntryDerivedData(
              kind: entry.ref.kind,
              kindData: kindData,
            );
      } else {
        await _s.ref
            .read(catalogTransportMutationsProvider)
            .upsertTransport(result.kindItem.toImportTransport());
      }
      if (entry != null) {
        if (result.entryUpdatePayload != null) {
          await coordinator.updateLibraryEntry(
            UpdateLibraryEntryCommand(
                libraryEntryRef: entry.ref,
                payload: result.entryUpdatePayload!),
            syncTracking: false,
          );
        }
        if (result.entryPersonalData != null) {
          final database = _s.ref.read(localDatabaseProvider);
          await LibraryEntryStore(database).updatePersonal(
              entry.ref.kind, entry.ref.id.value, result.entryPersonalData!);
        }
        if (result.customFieldEdits.isNotEmpty) {
          await _persistCustomFieldEdits(
            result.customFieldEdits,
            targetId: entry.ref.key,
            targetScope: CustomFieldTargetScope.libraryEntry,
            repository: customFieldRepo,
          );
        }
        for (final edit in result.itemImageEdits) {
          if (edit.deleted) {
            await itemImageRepo.delete(edit.id);
          } else if (edit.imageData != null) {
            await itemImageRepo.add(ItemImage(
              id: edit.id,
              libraryEntryRef: entry.ref,
              imageType: edit.imageType,
              imageData: edit.imageData!,
              caption: edit.caption,
              sortOrder: edit.sortOrder,
              createdAt: edit.createdAt ?? now,
            ));
          } else {
            await itemImageRepo.updateMetadata(
              edit.id,
              caption: edit.caption,
              imageType: edit.imageType,
              sortOrder: edit.sortOrder,
            );
          }
        }
      }
      for (final change in result.localChanges) {
        await change.persist(_s.ref.read(localDatabaseProvider));
      }
      if (entry != null) {
        final entries = _s.ref.read(libraryEntriesRepositoryProvider);
        final syncQueue = _s.ref.read(syncQueueRepositoryProvider);
        await syncQueue.enqueue(
          await entries.syncChangeForCurrentEntry(
            entry.ref,
            action: 'upsert',
            changedAt: now.toUtc(),
          ),
        );
      }
      if (wishlist != null && result.wishlist != null) {
        await wishlistMutations.updateWishlistItem(
          wishlist,
          catalogRef: result.wishlist!.catalogRef,
          targetPriceCents: result.wishlist!.targetPriceCents,
          currency: result.wishlist!.currency,
          notes: result.wishlist!.notes,
          notify: false,
        );
      }
      if (entry == null && result.tracking != null) {
        throw StateError(
          'Tracking changes require a local library entry. Add the item to '
          'the library before tracking it.',
        );
      }
      if (entry != null && result.tracking != null) {
        await trackingMutations.upsertTrackingState(
          entry.ref,
          sourceType: activeTrackingSummary?.sourceType,
          status: mediaTrackingStatusFromValue(result.tracking!.readStatus),
          rating: result.tracking!.rating,
          startedAt: result.tracking!.startedAt,
          finishedAt: result.tracking!.finishedAt,
          progressCurrent: result.tracking!.progressCurrent,
          progressTotal: result.tracking!.progressTotal,
          timesCompleted: result.tracking!.timesCompleted,
          notes: result.tracking!.notes,
          kindPatch: result.trackingKindPatch,
          replaceNullableFields: true,
          notify: false,
        );
      }
    });
  }

  Future<void> _persistCustomFieldEdits(
    Map<String, String?> edits, {
    required String targetId,
    required CustomFieldTargetScope targetScope,
    required CustomFieldRepository repository,
  }) async {
    await repository.deleteValuesForTarget(
      targetId: targetId,
      targetScope: targetScope,
    );
    final now = DateTime.now();
    await repository.upsertValues([
      for (final entry in edits.entries)
        CustomFieldValue(
          id: const Uuid().v4(),
          targetId: targetId,
          targetScope: targetScope,
          fieldDefinitionId: entry.key,
          value: entry.value,
          updatedAt: now,
        ),
    ]);
  }
}
