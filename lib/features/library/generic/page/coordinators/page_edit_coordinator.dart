part of '../generic_library_page.dart';

// ---------------------------------------------------------------------------
// Edit dialog launch + result persistence
// ---------------------------------------------------------------------------

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
        ownedSummary: item.source.ownedSummary,
        typedOwnedItem: item.source.typedOwnedItem,
        accent: _s.widget.accent,
        onAddOwned: () => _s._collectionActionCoordinator.runCollectionAction(
          (actions) => actions.addOwned(item),
        ),
        onRemoveOwned: item.source.isOwned != true
            ? null
            : () => _s._collectionActionCoordinator.confirmAndRemoveOwned(item),
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
          _s._linkedMetadataFilter = _s._linkedMetadataFilter?.value == value
              ? null
              : LibraryLinkedMetadataFilter(value: value);
          _s._selectedBucket = null;
          _s._selectedLetter = null;
        }),
      ),
    );
  }

  Future<void> showEditDialog(
    LibraryProjectionItem item,
    OwnedItemSummary? ownedItemOverride, {
    bool openMetadataCompareOnOpen = false,
    LibraryEditScope? scope,
  }) async {
    if (_s._isEditDialogInFlight) {
      return;
    }
    final catalogSource = item.source.catalogTransport;
    if (catalogSource == null) {
      return;
    }
    final catalogItem = catalogSource;
    _s._isEditDialogInFlight = true;
    final catalog = _s.ref.read(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final db = _s.ref.read(localDatabaseProvider);
    final customFieldRepo = CustomFieldRepository(db);
    final itemImageRepo = ItemImageRepository(db);
    final cached = (await CatalogSnapshotRepository(db)
        .findByRefs([catalogItem.catalogRef]))[catalogItem.catalogRef];
    final freshMetadataItem = cached == null
        ? catalogItem
        : LibraryAddCatalogTransport.fromItem(cached);
    OwnedItemSummary? owned = ownedItemOverride;
    final wishlistItems = _s.ref.read(wishlistProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <WishlistItem>[],
        );
    WishlistItem? wishlist = item.source.wishlistItem;
    if (wishlist == null ||
        wishlist.isDeleted ||
        (wishlist.catalogRef.rootId ?? wishlist.catalogRef.id) !=
            catalogItem.id) {
      wishlist = null;
      for (final candidate in wishlistItems) {
        if (!candidate.isDeleted &&
            (candidate.catalogRef.rootId ?? candidate.catalogRef.id) ==
                catalogItem.id) {
          wishlist = candidate;
          break;
        }
      }
    }
    final activeTrackingLifecycle = resolveActiveTrackingLifecycle(
      _s.ref.read(trackingPersistenceEntriesByCatalogRefProvider)[
              catalogItem.catalogRef] ??
          const <TrackingLifecycle>[],
      owned,
    );
    final shelfState = _s.ref.read(shelfProvider).asData?.value;
    final viewState = _s._viewState ?? _s._viewProfile.defaults();
    final projection = shelfState == null
        ? null
        : _s._projectionForShelf(shelfState, viewState);
    final viewItems =
        projection?.filteredItems ?? const <LibraryProjectionItem>[];
    var currentIndex = viewItems.indexWhere(
      (candidate) => candidate.node.id == item.node.id,
    );
    if (currentIndex < 0) {
      currentIndex = viewItems.indexWhere(
        (candidate) => candidate.source.catalogRef?.id == catalogItem.id,
      );
    }
    final previousItem = currentIndex > 0 ? viewItems[currentIndex - 1] : null;
    final nextItem = currentIndex >= 0 && currentIndex < viewItems.length - 1
        ? viewItems[currentIndex + 1]
        : null;
    LibraryProjectionItem? queuedNavigationItem;
    var navigationQueued = false;
    void queueEditNavigation(LibraryProjectionItem target) {
      if (navigationQueued) {
        return;
      }
      navigationQueued = true;
      queuedNavigationItem = target;
      final navigator = Navigator.of(_s.context, rootNavigator: true);
      if (!navigator.mounted || !navigator.canPop()) {
        return;
      }
      navigator.pop();
    }

    final baseRequest = LibraryEditDialogRequest(
      type: _s.widget.type,
      item: freshMetadataItem,
      ownedItem: owned,
      typedOwnedItem: item.source.typedOwnedItem,
      scope: scope ??
          _s.widget.type.hierarchy
              .editScopeForBrowserMode(_s._activeBrowserMode),
      wishlistItem: wishlist,
      trackingLifecycle: activeTrackingLifecycle,
      accent: _s.widget.accent,
      physicalFormats: physicalMediaFormatsForKind(
        catalog,
        _s.widget.type.kind,
      ),
      onPrevious:
          previousItem == null ? null : () => queueEditNavigation(previousItem),
      onNext: nextItem == null ? null : () => queueEditNavigation(nextItem),
      openMetadataCompareOnOpen: openMetadataCompareOnOpen,
    );
    try {
      if (!_s.mounted) return;
      final result = await showLibraryEditDialog(
        context: _s.context,
        request: baseRequest,
        requestLoader: () async {
          final definitionsFuture = customFieldRepo.listDefinitions(
            mediaKind: _s.widget.type.kind.apiValue,
            targetScope: owned != null
                ? CustomFieldTargetScope.ownedCopy
                : CustomFieldTargetScope.media,
          );
          final cfValuesFuture = owned != null
              ? customFieldRepo.listValuesForTarget(
                  targetId: owned.ref.id.value,
                  targetScope: CustomFieldTargetScope.ownedCopy,
                )
              : Future.value(const <CustomFieldValue>[]);
          final imagesFuture = owned != null
              ? itemImageRepo.listForOwnedRef(owned.ref)
              : Future.value(const <ItemImage>[]);

          final definitions = await definitionsFuture;
          final cfValues = await cfValuesFuture;
          final images = await imagesFuture;

          return baseRequest.copyWith(
            customFieldDefinitions: definitions,
            customFieldValues: cfValues,
            itemImages: images,
          );
        },
      );
      if (queuedNavigationItem != null) {
        _s._isEditDialogInFlight = false;
        if (!_s.mounted) {
          return;
        }
        unawaited(
          showEditDialog(
            queuedNavigationItem!,
            null,
          ),
        );
        return;
      }
      if (result == null || !_s.mounted) {
        return;
      }
      await _persistEditResult(
        result,
        owned: owned,
        wishlist: wishlist,
        activeTrackingLifecycle: activeTrackingLifecycle,
        catalogItem: catalogItem,
        customFieldRepo: customFieldRepo,
        itemImageRepo: itemImageRepo,
      );
      if (!_s.mounted) {
        return;
      }
      _s.ref.invalidate(shelfProvider);
      _s.ref.invalidate(
        libraryCustomFieldCacheProvider(_s.widget.type.kind.apiValue),
      );
      if (result.submitAction == LibraryEditSubmitAction.saveAndNext &&
          nextItem != null) {
        unawaited(
          showEditDialog(
            nextItem,
            null,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(_s.context).showSnackBar(
        SnackBar(
            content: Text('${_s.widget.type.identity.singularLabel} updated')),
      );
    } finally {
      _s._isEditDialogInFlight = false;
    }
  }

  Future<void> _persistEditResult(
    LibraryEditSelection result, {
    required OwnedItemSummary? owned,
    required WishlistItem? wishlist,
    required TrackingLifecycle? activeTrackingLifecycle,
    required LibraryAddCatalogTransport catalogItem,
    required CustomFieldRepository customFieldRepo,
    required ItemImageRepository itemImageRepo,
  }) async {
    final coordinator = _s.ref.read(collectionCommandCoordinatorProvider);
    final wishlistMutations = _s.ref.read(wishlistMutationsProvider);
    final trackingMutations = _s.ref.read(trackingMutationsProvider);

    await _s.ref.read(catalogItemMutationsProvider).updateSnapshot(
          CatalogImportSnapshot.fromItem(result.item.toTransportItem()),
        );
    final personal = result.personal;
    if (owned != null && personal != null) {
      final payload = result.ownedUpdatePayload;
      if (payload == null) {
        throw StateError(
          'Owned edit result did not contain a kind-owned update payload.',
        );
      }
      await coordinator.updateOwnedItem(
        UpdateOwnedItemCommand(
          ownedRef: owned.ref,
          payload: payload,
        ),
        syncTracking: false,
      );
      final tracking = result.tracking;
      if (tracking == null || activeTrackingLifecycle == null) {
        await trackingMutations.syncOwnedTrackingLifecycle(
          owned.ref,
          catalogRef: owned.catalogRef,
          isDigital: owned.isDigital,
          targetRef: tracking?.targetRef ?? owned.catalogRef,
          status: mediaTrackingStatusFromValue(tracking?.readStatus),
          rating: tracking?.rating,
          startedAt: tracking?.startedAt,
          finishedAt: tracking?.finishedAt,
          progressCurrent: tracking?.progressCurrent,
          progressTotal: tracking?.progressTotal,
          timesCompleted: tracking?.timesCompleted,
          notes: tracking?.notes,
          customizeLifecycle: result.trackingLifecycleMutation,
        );
      } else {
        final baseTracking = activeTrackingLifecycle.copyWith(
          catalogRef: tracking.targetRef ?? catalogItem.catalogRef,
          status: mediaTrackingStatusFromValue(tracking.readStatus),
          rating: tracking.rating,
          startedAt: tracking.startedAt,
          finishedAt: tracking.finishedAt,
          progressCurrent: tracking.progressCurrent,
          progressTotal: tracking.progressTotal,
          timesCompleted: tracking.timesCompleted,
          notes: tracking.notes,
        );
        final updatedTracking =
            result.trackingLifecycleMutation?.call(baseTracking) ??
                baseTracking;
        await trackingMutations.updateTrackingLifecycle(updatedTracking);
      }
      // Save custom field values
      final now = DateTime.now();
      final cfList = result.customFieldEdits.entries.map((e) {
        return CustomFieldValue(
          id: const Uuid().v4(),
          targetId: owned.ref.id.value,
          targetScope: CustomFieldTargetScope.ownedCopy,
          catalogRef: owned.catalogRef,
          fieldDefinitionId: e.key,
          value: e.value,
          updatedAt: now,
        );
      }).toList();
      await customFieldRepo.upsertValues(cfList);
      // Save item image edits
      for (final edit in result.itemImageEdits) {
        if (edit.deleted) {
          await itemImageRepo.delete(edit.id);
        } else if (edit.imageData != null) {
          await itemImageRepo.add(ItemImage(
            id: edit.id,
            ownedRef: owned.ref,
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
    if (owned == null &&
        activeTrackingLifecycle != null &&
        result.tracking != null) {
      await trackingMutations.upsertTrackingLifecycle(
        TrackingTarget.catalog(catalogItem.catalogRef),
        targetRef: result.tracking!.targetRef ?? catalogItem.catalogRef,
        sourceType: activeTrackingLifecycle.sourceType,
        status: mediaTrackingStatusFromValue(result.tracking!.readStatus),
        rating: result.tracking!.rating,
        startedAt: result.tracking!.startedAt,
        finishedAt: result.tracking!.finishedAt,
        progressCurrent: result.tracking!.progressCurrent ??
            activeTrackingLifecycle.progressCurrent,
        progressTotal: result.tracking!.progressTotal ??
            activeTrackingLifecycle.progressTotal,
        timesCompleted: result.tracking!.timesCompleted ??
            activeTrackingLifecycle.timesCompleted,
        notes: result.tracking!.notes ?? activeTrackingLifecycle.notes,
        customizeLifecycle: result.trackingLifecycleMutation,
        notify: false,
      );
    }
  }
}
