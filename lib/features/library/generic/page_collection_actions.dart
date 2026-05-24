part of 'page.dart';

final _random = math.Random();

/// Collection actions, context menu handling, bulk operations, and barcode
/// scanning for the library page.
extension _LibraryPageCollectionActions on _LibraryPageState {
  Future<void> runCollectionAction(
    Future<void> Function(LibraryCollectionActions actions) action,
  ) async {
    await action(ref.read(genericLibraryCollectionActionsProvider));
    if (mounted) {
      ref.invalidate(shelfProvider);
    }
  }

  Future<void> confirmAndRemoveOwned(LibraryProjectionItem item) async {
    final confirmed = await confirmSingleRemove(
      context,
      title: item.entry.title,
      itemLabel: widget.type.singularLabel.toLowerCase(),
    );
    if (!confirmed || !mounted) {
      return;
    }
    await runCollectionAction((actions) => actions.removeOwned(item));
  }

  Future<void> handleItemContextMenu(
    LibraryProjectionItem item,
    Offset position,
  ) async {
    _selectItem(item.entry.id);
    final result = await showLibraryItemContextMenu(
      context: context,
      position: position,
      entry: item.entry,
      accent: widget.accent,
    );
    if (result == null || !mounted) return;
    switch (result.action) {
      case LibraryItemContextAction.edit:
        unawaited(showEditDialog(item, item.source.ownedItem));
      case LibraryItemContextAction.addToOwned:
        await runCollectionAction((a) => a.addOwned(item));
      case LibraryItemContextAction.removeFromOwned:
        await confirmAndRemoveOwned(item);
      case LibraryItemContextAction.addToWishlist:
        await runCollectionAction((a) => a.addWishlist(item));
      case LibraryItemContextAction.removeFromWishlist:
        await runCollectionAction((a) => a.removeWishlist(item));
      case LibraryItemContextAction.removeTracking:
        final trackingEntries =
            ref.read(trackingEntriesByCatalogItemProvider)[item.entry.id] ??
                const <TrackingEntry>[];
        final active = resolveActiveTrackingEntry(trackingEntries, null);
        if (active != null) {
          await runCollectionAction(
            (a) => a.mutations.removeTrackingEntry(active),
          );
        }
      case LibraryItemContextAction.copyTitle:
        await Clipboard.setData(ClipboardData(text: item.entry.title));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Title copied')),
          );
        }
      case LibraryItemContextAction.copyBarcode:
        final barcode = item.entry.barcode;
        if (barcode != null && barcode.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: barcode));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Barcode copied')),
            );
          }
        }
    }
  }

  Future<void> scanBarcodeFlow() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BarcodeScanSheet(
        title: 'Scan ${widget.type.singularLabel.toLowerCase()} barcode',
        description:
            'Scan or enter a barcode, UPC, or ISBN. Collectarr will open Add ${widget.type.pluralLabel} with this code prefilled.',
        manualLabel: '${widget.type.singularLabel} barcode / UPC / ISBN',
        submitLabel: 'Continue to Add ${widget.type.pluralLabel}',
        leadingIcon: widget.type.workspace.icon,
      ),
    );
    if (code != null && mounted) {
      await showAddDialogFlow(barcode: code);
    }
  }

  Future<void> downloadAllCoversFlow(ShelfState shelfState) async {
    final db = ref.read(localDatabaseProvider);
    final imagesRepo = ItemImagesCacheRepository(db);
    final service = ImageDownloadService(imagesRepo: imagesRepo);

    final itemsToCover = <String, String?>{};
    for (final entry in shelfState.entries) {
      final ownedId = entry.ownedItem?.id;
      if (ownedId == null) continue;
      itemsToCover[ownedId] = entry.catalogItem?.displayCoverUrl;
    }
    if (itemsToCover.isEmpty) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading covers for ${itemsToCover.length} items...'),
        duration: const Duration(seconds: 2),
      ),
    );

    final results = await service.downloadCoversForItems(itemsToCover);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded ${results.length} covers.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void pickRandomItemFlow(LibraryProjection projection) {
    final items = projection.filteredItems;
    if (items.isEmpty) return;
    final random = items[_random.nextInt(items.length)];
    _selectItem(random.entry.id);
  }

  // ---- Bulk operations ----

  Future<void> bulkEditFlow(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final selection = await showBulkEditDialog(
      context,
      type: widget.type,
      selectedCount: _selection.selectedCount,
    );
    if (selection == null || !mounted) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    await bulkActions().editSelected(entries: entries, selection: selection);
    _rebuild(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> bulkMoveToOwnedFlow(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    await bulkActions().moveSelectedToOwned(
      entries,
      defaultCondition: widget.type.defaultCondition,
      defaultGrade: widget.type.defaultGrade,
    );
    _rebuild(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> bulkMoveToWishlistFlow(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    await bulkActions().moveSelectedToWishlist(entries);
    _rebuild(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> bulkRemoveFlow(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    final confirmed = await confirmBulkRemove(
      context,
      count: entries.length,
      itemLabel: widget.type.pluralLabel.toLowerCase(),
    );
    if (!confirmed || !mounted) return;
    await bulkActions().removeSelected(entries);
    _rebuild(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }
}
