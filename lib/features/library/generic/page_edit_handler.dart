part of 'page.dart';

// ---------------------------------------------------------------------------
// Edit dialog launch + result persistence
// ---------------------------------------------------------------------------

extension _LibraryPageEditHandlerExt on _LibraryPageState {
  void showDetailPage(LibraryProjectionItem item) {
    if (_canOpenVideoShelfDrilldown(item)) {
      _openVideoShelfDrilldown(item);
      return;
    }
    showLibraryDetailPage(
      context: context,
      request: LibraryDetailPageRequest(
        type: widget.type,
        entry: item.entry,
        ownedItem: item.source.ownedItem,
        accent: widget.accent,
        onAddOwned: () => runCollectionAction(
          (actions) => actions.addOwned(item),
        ),
        onRemoveOwned: item.source.ownedItem == null
            ? null
            : () => confirmAndRemoveOwned(item),
        onAddWishlist: () => runCollectionAction(
          (actions) => actions.addWishlist(item),
        ),
        onRemoveWishlist: item.source.isWishlisted
            ? () => runCollectionAction(
                  (actions) => actions.removeWishlist(item),
                )
            : null,
        onEdit: (ownedItem) => unawaited(showEditDialog(item, ownedItem)),
        onFilterByValue: (value) => _rebuild(() {
          _linkedMetadataFilter = _linkedMetadataFilter?.value == value
              ? null
              : LibraryLinkedMetadataFilter(value: value);
          _selectedBucket = null;
          _selectedLetter = null;
        }),
      ),
    );
  }

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
      } catch (error, stackTrace) {
        logRecoverableError(
          source: 'library_page',
          message:
              'Failed to load bundle releases while opening edit dialog for ${catalogItem.id}.',
          error: error,
          stackTrace: stackTrace,
        );
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
        features: personal.features,
        hdrFormats: personal.hdrFormats,
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
        episodeRatings:
          result.tracking?.episodeRatings ?? activeTrackingEntry?.episodeRatings,
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

class _VideoShelfReleaseDrilldownItem {
  const _VideoShelfReleaseDrilldownItem({
    required this.entry,
    required this.sourceLabel,
    required this.ownedCount,
    required this.wishlistCount,
    required this.node,
  });

  final LibraryWorkspaceEntry entry;
  final String sourceLabel;
  final int ownedCount;
  final int wishlistCount;
  final LibraryBrowserNode node;
}

class _VideoShelfReleaseDrilldown extends StatelessWidget {
  const _VideoShelfReleaseDrilldown({
    required this.titleItem,
    required this.items,
    required this.selectedReleaseId,
    required this.coverSize,
    required this.accent,
    required this.onBack,
    required this.onRefreshFromCore,
    required this.onSelectRelease,
    required this.onOpenTitleDetails,
  });

  final LibraryProjectionItem titleItem;
  final List<_VideoShelfReleaseDrilldownItem> items;
  final String? selectedReleaseId;
  final double coverSize;
  final Color accent;
  final VoidCallback onBack;
  final Future<void> Function() onRefreshFromCore;
  final ValueChanged<String> onSelectRelease;
  final VoidCallback onOpenTitleDetails;

  @override
  Widget build(BuildContext context) {
    final selected = items.where((item) => item.entry.id == selectedReleaseId).firstOrNull ??
        (items.isEmpty ? null : items.first);
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: kAppPanel,
            border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.28))),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to titles',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shelf releases',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        titleItem.entry.resolvedTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kAppTextMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenTitleDetails,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open browser'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: onRefreshFromCore,
                  icon: const Icon(Icons.travel_explore_outlined),
                  label: const Text('Search releases in Core'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 42,
                            color: accent.withValues(alpha: 0.9),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No release-specific copies or wishlist entries are anchored in your shelf for this title yet.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use Search releases in Core to refresh editions, or add a release-specific copy or wishlist entry from the detail browser.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: kAppTextMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (selected != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${selected.entry.variant ?? selected.entry.title} · ${selected.ownedCount} copies · ${selected.wishlistCount} wishlist · ${selected.sourceLabel}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: kAppTextMuted,
                                ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: LibraryWorkspaceGrid<_VideoShelfReleaseDrilldownItem>(
                        items: items,
                        emptyBuilder: (_) => const SizedBox.shrink(),
                        maxCrossAxisExtent: 430,
                        mainAxisExtent: (coverSize * 1.12).clamp(138.0, 174.0).toDouble(),
                        backgroundColor: kAppGridCanvas,
                        itemBuilder: (context, item) => LibraryWorkspaceCard(
                          key: ValueKey(item.entry.id),
                          entry: item.entry,
                          selected: item.entry.id == (selected?.entry.id ?? selectedReleaseId),
                          onTap: () => onSelectRelease(item.entry.id),
                          dateFormatter: formatDate,
                          moneyFormatter: formatMoney,
                          selectedColor: kAppSelection,
                          accentColor: accent,
                          mutedTextColor: kAppTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
