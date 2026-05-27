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
    LibraryProjection projection,
    LibraryProjectionItem item,
    Offset position,
  ) async {
    final contextSelectionIds = contextMenuSelectionItemIds(
      _selection.itemIds,
      clickedId: item.entry.id,
    );
    final selectionChanged =
        contextSelectionIds.length != _selection.itemIds.length ||
        !contextSelectionIds.containsAll(_selection.itemIds);
    if (selectionChanged ||
        _selectedId != item.entry.id) {
      _rebuild(() {
        _selection = _selection.replace(contextSelectionIds);
        _selectedId = item.entry.id;
        if (_selectionAnchorId == null ||
            !_selection.itemIds.contains(_selectionAnchorId)) {
          _selectionAnchorId = item.entry.id;
        }
      });
    }
    final isBatchSelection = contextSelectionIds.length > 1;
    final result = await showLibraryItemContextMenu(
      context: context,
      position: position,
      entry: item.entry,
      accent: widget.accent,
      selectedCount: contextSelectionIds.length,
    );
    if (result == null || !mounted) return;
    switch (result.action) {
      case LibraryItemContextAction.edit:
        if (isBatchSelection) {
          await bulkEditFlow(projection);
          return;
        }
        unawaited(showEditDialog(item, item.source.ownedItem));
      case LibraryItemContextAction.duplicate:
        if (isBatchSelection) {
          await bulkDuplicateFlow(projection);
          return;
        }
        await singleDuplicateFlow(item);
      case LibraryItemContextAction.addToOwned:
        if (isBatchSelection) {
          await bulkMoveToOwnedFlow(projection);
          return;
        }
        await runCollectionAction((a) => a.addOwned(item));
      case LibraryItemContextAction.removeFromOwned:
        if (isBatchSelection) {
          await bulkRemoveFlow(projection);
          return;
        }
        await confirmAndRemoveOwned(item);
      case LibraryItemContextAction.addToWishlist:
        if (isBatchSelection) {
          await bulkMoveToWishlistFlow(projection);
          return;
        }
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
    final prefill = await PrefillDefaults.load();
    await bulkActions().moveSelectedToOwned(
      entries,
      defaultCondition: prefill.condition ?? widget.type.defaultCondition,
      defaultGrade: prefill.grade ?? widget.type.defaultGrade,
      defaultLocationId: prefill.locationId,
      defaultStorageBox: prefill.legacyStorageBox,
      defaultReadStatus: prefill.readStatus,
      defaultTags: prefill.tags,
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

  Future<void> singleDuplicateFlow(LibraryProjectionItem item) async {
    final ownedItem = item.source.ownedItem;
    if (ownedItem == null) return;
    await bulkActions().duplicateSelected([item.source]);
    if (mounted) {
      ref.invalidate(shelfProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duplicated "${item.entry.title}"')),
      );
    }
  }

  Future<void> bulkDuplicateFlow(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duplicate items'),
        content: Text(
          'Create a copy of ${entries.length} '
          'item${entries.length == 1 ? '' : 's'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final count = await bulkActions().duplicateSelected(entries);
    _rebuild(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duplicated $count item${count == 1 ? '' : 's'}')),
      );
    }
  }

  Future<void> bulkRefreshMetadataFlow(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final selectedEntries = <LibraryWorkspaceEntry>[
      for (final item in projection.filteredItems)
        if (_selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (selectedEntries.isEmpty) return;
    final result = await showLibraryMetadataRefreshDialog(
      context: context,
      type: widget.type,
      accent: widget.accent,
      allEntries: selectedEntries,
      shownEntries: selectedEntries,
      selectedEntry: selectedEntries.first,
    );
    if (result == null || !mounted) return;
    _rebuild(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Metadata refresh finished: ${result.matched}/${result.targets} matched, '
          '${result.cached} cached, ${result.failed} failed.',
        ),
      ),
    );
  }

  Future<void> scanCoverFlow() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final api = ref.read(apiClientProvider);
      final response = await api.searchByCoverUpload(bytes);
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      final results = (response['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final queryPhash = response['query_phash'] as String? ?? '';

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matching covers found.')),
        );
        return;
      }

      await _showCoverScanResults(
        queryPhash: queryPhash,
        results: results,
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cover scan failed: $e')),
        );
      }
    }
  }

  Future<void> _showCoverScanResults({
    required String queryPhash,
    required List<Map<String, dynamic>> results,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cover Matches'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final match = results[index];
              final entityType = match['entity_type'] as String? ?? '';
              final entityId = match['entity_id'] as String? ?? '';
              final distance = match['hamming_distance'] as int? ?? 0;
              final publicUrl = match['public_url'] as String?;
              final confidence = ((64 - distance) / 64 * 100).round();

              return ListTile(
                leading: publicUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          publicUrl,
                          width: 40,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : const Icon(Icons.image, size: 40),
                title: Text('$entityType / ${entityId.substring(0, 8)}…'),
                subtitle: Text('$confidence% match (distance: $distance)'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  if (entityType == 'item') {
                    _selectItem(entityId);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
