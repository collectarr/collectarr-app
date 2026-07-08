part of '../generic_library_page.dart';

final _random = math.Random();

/// Collection actions, context menu handling, and bulk operations for the
/// library page.
class LibraryPageCollectionActionCoordinator {
  LibraryPageCollectionActionCoordinator(this._s);

  final GenericLibraryPageState _s;

  bool _isNonServerMetadataId(String id) {
    final normalized = id.trim().toLowerCase();
    return normalized.startsWith('preview-') ||
        normalized.startsWith('local-') ||
        normalized.startsWith('provider:');
  }

  bool canCompareMetadataWithServerItem(LibraryProjectionItem item) {
    if (!_s.widget.type.kindUiAdapter.supportsMetadataCompareWithServer(
      _s.widget.type,
    )) {
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
    await action(_s.ref.read(genericLibraryCollectionActionsProvider));
    if (_s.mounted) {
      _s.ref.invalidate(shelfProvider);
    }
  }

  Future<void> confirmAndRemoveOwned(LibraryProjectionItem item) async {
    final confirmed = await _s.confirmSingleRemove(
      _s.context,
      title: item.entry.title,
      itemLabel: _s.widget.type.singularLabel.toLowerCase(),
    );
    if (!confirmed || !_s.mounted) {
      return;
    }
    await runCollectionAction((actions) => actions.removeOwned(item));
  }

  LibraryProjectionItem? selectedProjectionItemFor(
      LibraryProjection projection) {
    final selectedId = _s._selectedId;
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

  Future<void> handleItemContextMenu(
    LibraryProjection projection,
    LibraryProjectionItem item,
    Offset position,
  ) async {
    final contextSelectionIds = <String>{item.entry.id};
    final selectionChanged =
        contextSelectionIds.length != _s._selection.itemIds.length ||
            !contextSelectionIds.containsAll(_s._selection.itemIds);
    if (selectionChanged || _s._selectedId != item.entry.id) {
      _s._rebuild(() {
        _s._selection = _s._selection.replace(contextSelectionIds);
        _s._selectedId = item.entry.id;
        if (_s._selectionAnchorId == null ||
            !_s._selection.itemIds.contains(_s._selectionAnchorId)) {
          _s._selectionAnchorId = item.entry.id;
        }
      });
    }
    final isBatchSelection = contextSelectionIds.length > 1;
    final result = await showLibraryItemContextMenu(
      context: _s.context,
      position: position,
      entry: item.entry,
      accent: _s.widget.accent,
      selectedCount: contextSelectionIds.length,
      supportsMetadataCompare: canCompareMetadataWithServerItem(item),
    );
    if (result == null || !_s.mounted) return;
    switch (result.action) {
      case LibraryItemContextAction.edit:
        if (isBatchSelection) {
          await bulkEditFlow(projection);
          return;
        }
        unawaited(_s._editCoordinator.showEditDialog(item, item.source.ownedItem));
      case LibraryItemContextAction.compareMetadataWithServer:
        if (isBatchSelection) {
          return;
        }
        await _s._metadataCoordinator.compareMetadataWithServerFlow(
          projection,
          item: item,
        );
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
            _s.ref.read(trackingEntriesByCatalogItemProvider)[item.entry.id] ??
                const <TrackingEntry>[];
        final active = resolveActiveTrackingEntry(trackingEntries, null);
        if (active != null) {
          await runCollectionAction(
            (a) => a.mutations.removeTrackingEntry(active),
          );
        }
      case LibraryItemContextAction.copyTitle:
        await Clipboard.setData(ClipboardData(text: item.entry.title));
        if (_s.mounted) {
          ScaffoldMessenger.of(_s.context).showSnackBar(
            const SnackBar(content: Text('Title copied')),
          );
        }
      case LibraryItemContextAction.copyBarcode:
        final barcode = item.entry.barcode;
        if (barcode != null && barcode.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: barcode));
          if (_s.mounted) {
            ScaffoldMessenger.of(_s.context).showSnackBar(
              const SnackBar(content: Text('Barcode copied')),
            );
          }
        }
    }
  }

  Future<void> scanBarcodeFlow() async {
    final code = await showModalBottomSheet<String>(
      context: _s.context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BarcodeScanSheet(
        title: 'Scan ${_s.widget.type.singularLabel.toLowerCase()} barcode',
        description:
            'Scan or enter a barcode, UPC, or ISBN. Collectarr will open Add ${_s.widget.type.pluralLabel} with this code prefilled.',
        manualLabel: '${_s.widget.type.singularLabel} barcode / UPC / ISBN',
        submitLabel: 'Continue to Add ${_s.widget.type.pluralLabel}',
        leadingIcon: _s.widget.type.workspace.icon,
      ),
    );
    if (code != null && _s.mounted) {
      await _s._dialogCoordinator.showAddDialogFlow(barcode: code);
    }
  }

  void pickRandomItemFlow(LibraryProjection projection) {
    final items = projection.filteredItems;
    if (items.isEmpty) {
      if (!_s.mounted) {
        return;
      }
      ScaffoldMessenger.of(_s.context).showSnackBar(
        const SnackBar(content: Text('No items available for random pick.')),
      );
      return;
    }
    final random = items[_random.nextInt(items.length)];
    _s._selectItem(random.entry.id);
  }

  // ---- Bulk operations ----

  Future<void> bulkEditFlow(LibraryProjection? projection) async {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final selection = await _s.showBulkEditDialog(
      _s.context,
      type: _s.widget.type,
      selectedCount: _s._selection.selectedCount,
    );
    if (selection == null || !_s.mounted) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _s._selection.itemIds,
    );
    await _s.bulkActions().editSelected(entries: entries, selection: selection);
    _s._rebuild(() => _s._selection = _s._selection.clear());
    _s.ref.invalidate(shelfProvider);
  }

  Future<void> bulkMoveToOwnedFlow(LibraryProjection? projection) async {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _s._selection.itemIds,
    );
    final prefill = await PrefillDefaults.load();
    await _s.bulkActions().moveSelectedToOwned(
      entries,
      defaultCondition: prefill.condition ?? _s.widget.type.defaultCondition,
      defaultGrade: prefill.grade ?? _s.widget.type.defaultGrade,
      defaultLocationId: prefill.locationId,
      defaultReadStatus: prefill.readStatus,
      defaultTags: prefill.tags,
    );
    _s._rebuild(() => _s._selection = _s._selection.clear());
    _s.ref.invalidate(shelfProvider);
  }

  Future<void> bulkMoveToWishlistFlow(LibraryProjection? projection) async {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _s._selection.itemIds,
    );
    await _s.bulkActions().moveSelectedToWishlist(entries);
    _s._rebuild(() => _s._selection = _s._selection.clear());
    _s.ref.invalidate(shelfProvider);
  }

  Future<void> bulkRemoveFlow(LibraryProjection? projection) async {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _s._selection.itemIds,
    );
    final confirmed = await _s.confirmBulkRemove(
      _s.context,
      count: entries.length,
      itemLabel: _s.widget.type.pluralLabel.toLowerCase(),
    );
    if (!confirmed || !_s.mounted) return;
    await _s.bulkActions().removeSelected(entries);
    _s._rebuild(() => _s._selection = _s._selection.clear());
    _s.ref.invalidate(shelfProvider);
  }

  Future<void> singleDuplicateFlow(LibraryProjectionItem item) async {
    final ownedItem = item.source.ownedItem;
    if (ownedItem == null) return;
    await _s.bulkActions().duplicateSelected([item.source]);
    if (_s.mounted) {
      _s.ref.invalidate(shelfProvider);
      ScaffoldMessenger.of(_s.context).showSnackBar(
        SnackBar(content: Text('Duplicated "${item.entry.title}"')),
      );
    }
  }

  Future<void> bulkDuplicateFlow(LibraryProjection? projection) async {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _s._selection.itemIds,
    );
    final confirmed = await showDialog<bool>(
      context: _s.context,
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
    if (confirmed != true || !_s.mounted) return;
    final count = await _s.bulkActions().duplicateSelected(entries);
    _s._rebuild(() => _s._selection = _s._selection.clear());
    _s.ref.invalidate(shelfProvider);
    if (_s.mounted) {
      ScaffoldMessenger.of(_s.context).showSnackBar(
        SnackBar(
            content: Text('Duplicated $count item${count == 1 ? '' : 's'}')),
      );
    }
  }
}