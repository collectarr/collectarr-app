part of 'page.dart';

final _random = math.Random();

/// Collection actions, context menu handling, bulk operations, and barcode
/// scanning for the library page.
extension _GenericLibraryPageCollectionActions on GenericLibraryPageState {
  bool _isNonServerMetadataId(String id) {
    final normalized = id.trim().toLowerCase();
    return normalized.startsWith('preview-') ||
        normalized.startsWith('local-') ||
        normalized.startsWith('provider:');
  }

  bool canCompareMetadataWithServerItem(LibraryProjectionItem item) {
    if (!supportsMetadataCompareWithServer()) {
      return false;
    }
    final catalogId = item.source.catalogItem?.id ?? item.entry.id;
    if (_isNonServerMetadataId(catalogId)) {
      return false;
    }
    if (item.entry.hasMissingMetadata) {
      return false;
    }
    return true;
  }

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

  bool supportsMetadataCompareWithServer() {
    final kind = widget.type.workspace.kind.apiValue;
    return kind == 'comic' || kind == 'music';
  }

  LibraryProjectionItem? selectedProjectionItemFor(
      LibraryProjection projection) {
    final selectedId = _selectedId;
    if (selectedId == null) {
      return null;
    }
    for (final item in projection.filteredItems) {
      if (item.entry.id == selectedId) {
        return item;
      }
    }
    return null;
  }

  Future<void> compareMetadataWithServerFlow(
    LibraryProjection projection, {
    LibraryProjectionItem? item,
  }) async {
    if (!supportsMetadataCompareWithServer()) {
      return;
    }
    final targetItem = item ?? selectedProjectionItemFor(projection);
    if (targetItem == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an item first.')),
      );
      return;
    }
    if (!canCompareMetadataWithServerItem(targetItem)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This item cannot be compared with server metadata.',
          ),
        ),
      );
      return;
    }
    await showEditDialog(
      targetItem,
      targetItem.source.ownedItem,
      openMetadataCompareOnOpen: true,
    );
  }

  Future<void> handleItemContextMenu(
    LibraryProjection projection,
    LibraryProjectionItem item,
    Offset position,
  ) async {
    final contextSelectionIds = <String>{item.entry.id};
    final selectionChanged =
        contextSelectionIds.length != _selection.itemIds.length ||
            !contextSelectionIds.containsAll(_selection.itemIds);
    if (selectionChanged || _selectedId != item.entry.id) {
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
      supportsMetadataCompare: canCompareMetadataWithServerItem(item),
    );
    if (result == null || !mounted) return;
    switch (result.action) {
      case LibraryItemContextAction.edit:
        if (isBatchSelection) {
          await bulkEditFlow(projection);
          return;
        }
        unawaited(showEditDialog(item, item.source.ownedItem));
      case LibraryItemContextAction.compareMetadataWithServer:
        if (isBatchSelection) {
          return;
        }
        await compareMetadataWithServerFlow(projection, item: item);
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
      builder: (ctx) => AccentAlertDialog(
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
        SnackBar(
            content: Text('Duplicated $count item${count == 1 ? '' : 's'}')),
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

    _rebuild(() => _isScanningCover = true);

    try {
      final api = ref.read(apiClientProvider);
      final response = await api.searchByCoverUpload(bytes);
      if (!mounted) return;

      _rebuild(() => _isScanningCover = false);

      final results =
          (response['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
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
        _rebuild(() => _isScanningCover = false);
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
      builder: (dialogContext) => AccentAlertDialog(
        backgroundColor: appPalette(dialogContext).panel,
        title: const Text('Cover Matches'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final match = results[index];
              final entityType = match['entity_type'] as String? ?? '';
              final entityId = match['entity_id'] as String? ?? '';
              final distance = match['hamming_distance'] as int? ?? 0;
              final publicUrl = match['public_url'] as String?;
              final confidence = ((64 - distance) / 64 * 100).round();

              return ListTile(
                leading: publicUrl != null && publicUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: publicUrl,
                          width: 40,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : const Icon(Icons.image, size: 40),
                title: Text(
                    '$entityType / ${entityId.length > 8 ? '${entityId.substring(0, 8)}…' : entityId}'),
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
