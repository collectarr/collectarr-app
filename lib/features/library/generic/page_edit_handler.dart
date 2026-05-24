part of 'page.dart';

// ---------------------------------------------------------------------------
// Edit dialog launch + result persistence
// ---------------------------------------------------------------------------

extension _LibraryPageEditHandlerExt on _LibraryPageState {
  Future<void> showEditDialog(
    LibraryProjectionItem item,
    OwnedItem? ownedItemOverride,
  ) async {
    final catalogItem = item.source.catalogItem;
    if (catalogItem == null) {
      return;
    }
    final catalog = ref.read(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final db = ref.read(localDatabaseProvider);
    final customFieldRepo = CustomFieldRepository(db);
    final itemImageRepo = ItemImageRepository(db);
    final owned = ownedItemOverride ?? item.source.ownedItem;
    final wishlist = item.source.wishlistItem;
    final activeTrackingEntry = resolveActiveTrackingEntry(
      ref.read(trackingEntriesByCatalogItemProvider)[catalogItem.id] ??
          const <TrackingEntry>[],
      owned,
    );
    final Future<List<BundleReleaseSummary>> bundleReleases = (() async {
      try {
        return await ref.read(apiClientProvider).getItemBundleReleases(catalogItem.id);
      } catch (_) {
        return const <BundleReleaseSummary>[];
      }
    })();
    final definitions = await customFieldRepo.listDefinitions(
      mediaKind: widget.type.workspace.kind.apiValue,
    );
    final cfValues = owned != null
        ? await customFieldRepo.listValuesForItem(owned.id)
        : <dynamic>[];
    final images =
        owned != null ? await itemImageRepo.listForItem(owned.id) : <dynamic>[];
    final availableBundleReleases = await bundleReleases;
    if (!mounted) return;
    final result = await showLibraryEditDialog(
      context: context,
      request: LibraryEditDialogRequest(
        type: widget.type,
        item: LibraryMetadataItem.fromCatalogItem(catalogItem),
        ownedItem: owned,
        wishlistItem: wishlist,
        trackingEntry: activeTrackingEntry,
        accent: widget.accent,
        availableBundleReleases: availableBundleReleases,
        physicalFormats: physicalMediaFormatsForKind(
          catalog,
          widget.type.workspace.kind,
        ),
        customFieldDefinitions: definitions,
        customFieldValues: cfValues.cast(),
        itemImages: images.cast(),
      ),
    );
    if (result == null || !mounted) {
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
    if (!mounted) {
      return;
    }
    ref.invalidate(shelfProvider);
    unawaited(
      loadCustomFieldValues(mediaKind: widget.type.workspace.kind.apiValue),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.type.singularLabel} updated')),
    );
  }

  Future<void> _persistEditResult(
    LibraryEditSelection result, {
    required OwnedItem? owned,
    required dynamic wishlist,
    required TrackingEntry? activeTrackingEntry,
    required CatalogItem catalogItem,
    required CustomFieldRepository customFieldRepo,
    required ItemImageRepository itemImageRepo,
  }) async {
    final mutations = ref.read(collectionMutationsProvider);
    await mutations.updateCatalogSnapshot(
      result.item.toCatalogItem(),
      notify: owned == null && wishlist == null,
    );
    final personal = result.personal;
    if (owned != null && personal != null) {
      final updatedOwned = await mutations.updateItem(
        owned,
        anchorType: personal.anchorType,
        editionId: personal.editionId,
        variantId: personal.variantId,
        bundleReleaseId: personal.bundleReleaseId,
        condition: personal.condition,
        grade: personal.grade,
        purchaseDate: personal.purchaseDate,
        pricePaidCents: personal.pricePaidCents,
        currency: personal.currency,
        personalNotes: personal.personalNotes,
        quantity: personal.quantity,
        storageBox: personal.locationChanged ? null : owned.storageBox,
        locationId:
            personal.locationChanged ? personal.locationId : owned.locationId,
        indexNumber: owned.indexNumber,
        coverPriceCents: personal.coverPriceCents,
        rawOrSlabbed: personal.rawOrSlabbed,
        gradingCompany: personal.gradingCompany,
        graderNotes: personal.graderNotes,
        signedBy: personal.signedBy,
        keyComic: personal.keyComic,
        keyReason: personal.keyReason,
        rating: result.tracking?.rating,
        readStatus: result.tracking?.readStatus,
        startedAt: result.tracking?.startedAt,
        finishedAt: result.tracking?.finishedAt,
        tags: personal.tags,
        soldAt: personal.soldAt,
        sellPriceCents: personal.sellPriceCents,
        soldTo: personal.soldTo,
        syncTracking: false,
        notify: false,
      );
      await mutations.syncOwnedTrackingEntry(
        updatedOwned,
        editionId: result.tracking?.editionId,
        variantId: result.tracking?.variantId,
        status: result.tracking?.readStatus,
        rating: result.tracking?.rating,
        startedAt: result.tracking?.startedAt,
        finishedAt: result.tracking?.finishedAt,
        progressCurrent:
          result.tracking?.progressCurrent ?? activeTrackingEntry?.progressCurrent,
        progressTotal:
          result.tracking?.progressTotal ?? activeTrackingEntry?.progressTotal,
        timesCompleted:
          result.tracking?.timesCompleted ?? activeTrackingEntry?.timesCompleted,
        notes: result.tracking?.notes ?? activeTrackingEntry?.notes,
        seasonNumber:
          result.tracking?.seasonNumber ?? activeTrackingEntry?.seasonNumber,
        episodeNumber:
          result.tracking?.episodeNumber ?? activeTrackingEntry?.episodeNumber,
      );
      // Save custom field values
      final now = DateTime.now();
      final cfList = result.customFieldEdits.entries.map((e) {
        return CustomFieldValue(
          id: const Uuid().v4(),
          ownedItemId: owned.id,
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
            imageData: edit.imageData!,
            caption: edit.caption,
            sortOrder: edit.sortOrder,
            createdAt: now,
          ));
        } else {
          await itemImageRepo.updateCaption(edit.id, edit.caption);
        }
      }
    }
    if (wishlist != null && result.wishlist != null) {
      await mutations.updateWishlistItem(
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
    if (owned == null && activeTrackingEntry != null && result.tracking != null) {
      await mutations.upsertTrackingEntry(
        catalogItem.id,
        editionId: result.tracking!.editionId,
        variantId: result.tracking!.variantId,
        sourceType: activeTrackingEntry.sourceType,
        status: result.tracking!.readStatus,
        rating: result.tracking!.rating,
        startedAt: result.tracking!.startedAt,
        finishedAt: result.tracking!.finishedAt,
        progressCurrent:
          result.tracking!.progressCurrent ?? activeTrackingEntry.progressCurrent,
        progressTotal:
          result.tracking!.progressTotal ?? activeTrackingEntry.progressTotal,
        timesCompleted:
          result.tracking!.timesCompleted ?? activeTrackingEntry.timesCompleted,
        notes: result.tracking!.notes ?? activeTrackingEntry.notes,
        seasonNumber:
          result.tracking!.seasonNumber ?? activeTrackingEntry.seasonNumber,
        episodeNumber:
          result.tracking!.episodeNumber ?? activeTrackingEntry.episodeNumber,
        notify: false,
      );
    }
  }
}
