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
        ownedItem: item.source.ownedItem,
        accent: _s.widget.accent,
        onAddOwned: () => _s._collectionActionCoordinator.runCollectionAction(
          (actions) => actions.addOwned(item),
        ),
        onRemoveOwned: item.source.ownedItem == null
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
        onEdit: (ownedItem) => unawaited(showEditDialog(item, ownedItem)),
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
    OwnedItem? ownedItemOverride, {
    bool openMetadataCompareOnOpen = false,
    LibraryEditScope? scope,
  }) async {
    if (_s._isEditDialogInFlight) {
      return;
    }
    final CatalogItem? catalogItem = item.source.catalogItem;
    if (catalogItem == null) {
      return;
    }
    _s._isEditDialogInFlight = true;
    final catalog = _s.ref.read(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final db = _s.ref.read(localDatabaseProvider);
    final customFieldRepo = CustomFieldRepository(db);
    final itemImageRepo = ItemImageRepository(db);
    final cached = (await LibraryCatalogRepository(db)
        .findByIds({catalogItem.id}))[catalogItem.id];
    final freshMetadataItem =
        cached != null ? typedCatalogItemFromCatalogItem(cached) : catalogItem;
    final ownedItems = _s.ref.read(collectionProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <OwnedItem>[],
        );
    OwnedItem? owned = ownedItemOverride;
    final overrideOwnedId = owned?.id;
    if (overrideOwnedId != null) {
      for (final candidate in ownedItems) {
        if (candidate.id == overrideOwnedId) {
          owned = candidate;
          break;
        }
      }
    }
    owned ??= item.source.ownedItem;
    if (owned == null || owned.isDeleted || owned.itemId != catalogItem.id) {
      for (final candidate in ownedItems) {
        if (!candidate.isDeleted && candidate.itemId == catalogItem.id) {
          owned = candidate;
          break;
        }
      }
    }
    final wishlistItems = _s.ref.read(wishlistProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <WishlistItem>[],
        );
    WishlistItem? wishlist = item.source.wishlistItem;
    if (wishlist == null ||
        wishlist.isDeleted ||
        wishlist.itemId != catalogItem.id) {
      wishlist = null;
      for (final candidate in wishlistItems) {
        if (!candidate.isDeleted && candidate.itemId == catalogItem.id) {
          wishlist = candidate;
          break;
        }
      }
    }
    final activeTrackingEntry = resolveActiveTrackingEntry(
      _s.ref.read(trackingEntriesByCatalogItemProvider)[catalogItem.id] ??
          const <TrackingEntry>[],
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
        (candidate) => candidate.source.catalogItem?.id == catalogItem.id,
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
      scope: scope ??
          _s.widget.type.hierarchy
              .editScopeForBrowserMode(_s._activeBrowserMode),
      wishlistItem: wishlist,
      trackingEntry: activeTrackingEntry,
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
                  targetId: owned.id,
                  targetScope: CustomFieldTargetScope.ownedCopy,
                )
              : Future.value(const <CustomFieldValue>[]);
          final imagesFuture = owned != null
              ? itemImageRepo.listForItem(owned.id)
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
            queuedNavigationItem!.source.ownedItem,
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
        activeTrackingEntry: activeTrackingEntry,
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
            nextItem.source.ownedItem,
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
    required OwnedItem? owned,
    required WishlistItem? wishlist,
    required TrackingEntry? activeTrackingEntry,
    required CatalogItem catalogItem,
    required CustomFieldRepository customFieldRepo,
    required ItemImageRepository itemImageRepo,
  }) async {
    final ownedMutations = _s.ref.read(ownedItemMutationsProvider);
    final coordinator = _s.ref.read(collectionCommandCoordinatorProvider);
    final wishlistMutations = _s.ref.read(wishlistMutationsProvider);
    final trackingMutations = _s.ref.read(trackingMutationsProvider);

    await ownedMutations.updateCatalogSnapshot(
      result.item,
    );
    final personal = result.personal;
    if (owned != null && personal != null) {
      final updateCmd = UpdateOwnedItemCommand(
        ownedItemId: owned.id,
        quantity: Patch.set(personal.quantity),
        condition: personal.condition != null
            ? Patch.set(personal.condition)
            : const Patch.clear(),
        grade: personal.grade != null
            ? Patch.set(personal.grade)
            : const Patch.clear(),
        personalNotes: personal.personalNotes != null
            ? Patch.set(personal.personalNotes)
            : const Patch.clear(),
        locationId: personal.locationChanged
            ? (personal.locationId != null
                ? Patch.set(personal.locationId)
                : const Patch.clear())
            : (owned.locationId != null
                ? Patch.set(owned.locationId)
                : const Patch.clear()),
        purchaseStore: personal.purchaseStore != null
            ? Patch.set(personal.purchaseStore)
            : const Patch.clear(),
        collectionStatus: personal.collectionStatus != null
            ? Patch.set(personal.collectionStatus)
            : const Patch.clear(),
        tags: personal.tags != null
            ? Patch.set(personal.tags)
            : const Patch.clear(),
        soldAt: personal.soldAt != null
            ? Patch.set(personal.soldAt)
            : const Patch.clear(),
        sellPriceCents: personal.sellPriceCents != null
            ? Patch.set(personal.sellPriceCents)
            : const Patch.clear(),
        soldTo: personal.soldTo != null
            ? Patch.set(personal.soldTo)
            : const Patch.clear(),
        marketValueCents: personal.marketValueCents != null
            ? Patch.set(personal.marketValueCents)
            : const Patch.clear(),
        details: Patch.set(
          _s.widget.type.buildPersonalDetailsDraft(personal),
        ),
      );
      await coordinator.updateOwnedItem(
        updateCmd,
        syncTracking: false,
      );
      await trackingMutations.syncOwnedTrackingEntry(
        owned,
        editionId: result.tracking?.editionId,
        variantId: result.tracking?.variantId,
        status: mediaTrackingStatusFromValue(result.tracking?.readStatus),
        rating: result.tracking?.rating,
        startedAt: result.tracking?.startedAt,
        finishedAt: result.tracking?.finishedAt,
        progressCurrent: result.tracking?.progressCurrent ??
            activeTrackingEntry?.progressCurrent,
        progressTotal: result.tracking?.progressTotal ??
            activeTrackingEntry?.progressTotal,
        timesCompleted: result.tracking?.timesCompleted ??
            activeTrackingEntry?.timesCompleted,
        notes: result.tracking?.notes ?? activeTrackingEntry?.notes,
      );
      // Save custom field values
      final now = DateTime.now();
      final cfList = result.customFieldEdits.entries.map((e) {
        return CustomFieldValue(
          id: const Uuid().v4(),
          targetId: owned.id,
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
            ownedItemId: owned.id,
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
        anchorType: result.wishlist!.anchorType,
        editionId: result.wishlist!.editionId,
        variantId: result.wishlist!.variantId,
        bundleReleaseId: result.wishlist!.bundleReleaseId,
        targetPriceCents: result.wishlist!.targetPriceCents,
        currency: result.wishlist!.currency,
        notes: result.wishlist!.notes,
        notify: false,
      );
    }
    if (owned == null &&
        activeTrackingEntry != null &&
        result.tracking != null) {
      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(catalogItem.catalogRef),
        editionId: result.tracking!.editionId,
        variantId: result.tracking!.variantId,
        sourceType: activeTrackingEntry.sourceType,
        status: mediaTrackingStatusFromValue(result.tracking!.readStatus),
        rating: result.tracking!.rating,
        startedAt: result.tracking!.startedAt,
        finishedAt: result.tracking!.finishedAt,
        progressCurrent: result.tracking!.progressCurrent ??
            activeTrackingEntry.progressCurrent,
        progressTotal:
            result.tracking!.progressTotal ?? activeTrackingEntry.progressTotal,
        timesCompleted: result.tracking!.timesCompleted ??
            activeTrackingEntry.timesCompleted,
        notes: result.tracking!.notes ?? activeTrackingEntry.notes,
        customizeEntry: result.trackingEntryMutation,
        notify: false,
      );
    }
  }
}
