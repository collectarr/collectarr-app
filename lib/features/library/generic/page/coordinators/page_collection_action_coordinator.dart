import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/collection_actions.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_item_context_menu.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _random = math.Random();

/// Collection actions, context menu handling, and bulk operations for the
/// library page.
class LibraryPageCollectionActionCoordinator {
  LibraryPageCollectionActionCoordinator(
    this._page, {
    required LibraryPageEditDialogLauncher showEditDialog,
    required LibraryPageCompareMetadataWithServer compareMetadataWithServer,
    required LibraryPageAddDialogLauncher showAddDialog,
  })  : _showEditDialog = showEditDialog,
        _compareMetadataWithServer = compareMetadataWithServer,
        _showAddDialog = showAddDialog;

  final LibraryPageCoordinatorContext _page;
  final LibraryPageEditDialogLauncher _showEditDialog;
  final LibraryPageCompareMetadataWithServer _compareMetadataWithServer;
  final LibraryPageAddDialogLauncher _showAddDialog;

  bool _isNonServerMetadataId(String id) {
    final normalized = id.trim().toLowerCase();
    return normalized.startsWith('preview-') ||
        normalized.startsWith('local-') ||
        normalized.startsWith('provider:');
  }

  bool canCompareMetadataWithServerItem(LibraryProjectionItem item) {
    if (!_page.type.kindUiAdapter.supportsMetadataCompareWithServer(
      _page.type,
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
    await action(_page.ref.read(genericLibraryCollectionActionsProvider));
    if (_page.mounted) {
      _page.invalidateShelf();
    }
  }

  Future<void> confirmAndRemoveOwned(LibraryProjectionItem item) async {
    final confirmed = await _page.confirmSingleRemove(
      _page.context,
      title: item.entry.title,
      itemLabel: _page.type.singularLabel.toLowerCase(),
    );
    if (!confirmed || !_page.mounted) {
      return;
    }
    await runCollectionAction((actions) => actions.removeOwned(item));
  }

  LibraryProjectionItem? selectedProjectionItemFor(
    LibraryProjection projection,
  ) {
    final selectedId = _page.selectedId;
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
        contextSelectionIds.length != _page.selection.itemIds.length ||
            !contextSelectionIds.containsAll(_page.selection.itemIds);
    if (selectionChanged || _page.selectedId != item.entry.id) {
      _page.rebuild(() {
        _page.selection = _page.selection.replace(contextSelectionIds);
        _page.selectedId = item.entry.id;
        if (_page.selectionAnchorId == null ||
            !_page.selection.itemIds.contains(_page.selectionAnchorId)) {
          _page.selectionAnchorId = item.entry.id;
        }
      });
    }
    final isBatchSelection = contextSelectionIds.length > 1;
    final result = await showLibraryItemContextMenu(
      context: _page.context,
      position: position,
      entry: item.entry,
      accent: _page.accent,
      selectedCount: contextSelectionIds.length,
      supportsMetadataCompare: canCompareMetadataWithServerItem(item),
    );
    if (result == null || !_page.mounted) return;
    switch (result.action) {
      case LibraryItemContextAction.edit:
        if (isBatchSelection) {
          await bulkEditFlow(projection);
          return;
        }
        unawaited(_showEditDialog(item, item.source.ownedItem));
      case LibraryItemContextAction.compareMetadataWithServer:
        if (isBatchSelection) {
          return;
        }
        await _compareMetadataWithServer(
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
        final trackingEntries = _page.ref
                .read(trackingEntriesByCatalogItemProvider)[item.entry.id] ??
            const <TrackingEntry>[];
        final active = resolveActiveTrackingEntry(trackingEntries, null);
        if (active != null) {
          await runCollectionAction(
            (a) => a.mutations.removeTrackingEntry(active),
          );
        }
      case LibraryItemContextAction.copyTitle:
        await Clipboard.setData(ClipboardData(text: item.entry.title));
        if (_page.mounted) {
          ScaffoldMessenger.of(_page.context).showSnackBar(
            const SnackBar(content: Text('Title copied')),
          );
        }
      case LibraryItemContextAction.copyBarcode:
        final barcode = item.entry.barcode;
        if (barcode != null && barcode.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: barcode));
          if (_page.mounted) {
            ScaffoldMessenger.of(_page.context).showSnackBar(
              const SnackBar(content: Text('Barcode copied')),
            );
          }
        }
    }
  }

  Future<void> scanBarcodeFlow() async {
    final code = await showModalBottomSheet<String>(
      context: _page.context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BarcodeScanSheet(
        title: 'Scan ${_page.type.singularLabel.toLowerCase()} barcode',
        description:
            'Scan or enter a barcode, UPC, or ISBN. Collectarr will open Add ${_page.type.pluralLabel} with this code prefilled.',
        manualLabel: '${_page.type.singularLabel} barcode / UPC / ISBN',
        submitLabel: 'Continue to Add ${_page.type.pluralLabel}',
        leadingIcon: _page.type.workspace.icon,
      ),
    );
    if (code != null && _page.mounted) {
      await _showAddDialog(barcode: code);
    }
  }

  void pickRandomItemFlow(LibraryProjection projection) {
    final items = projection.filteredItems;
    if (items.isEmpty) {
      if (!_page.mounted) {
        return;
      }
      ScaffoldMessenger.of(_page.context).showSnackBar(
        const SnackBar(content: Text('No items available for random pick.')),
      );
      return;
    }
    final random = items[_random.nextInt(items.length)];
    _page.selectItem(random.entry.id);
  }

  Future<void> bulkEditFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final selection = await _page.showBulkEditDialog(
      _page.context,
      type: _page.type,
      selectedCount: _page.selection.selectedCount,
    );
    if (selection == null || !_page.mounted) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _page.selection.itemIds,
    );
    await _page
        .bulkActions()
        .editSelected(entries: entries, selection: selection);
    _page.rebuild(_page.clearSelection);
    _page.invalidateShelf();
  }

  Future<void> bulkMoveToOwnedFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _page.selection.itemIds,
    );
    final prefill = await PrefillDefaults.load();
    await _page.bulkActions().moveSelectedToOwned(
          entries,
          defaultCondition: prefill.condition ?? _page.type.defaultCondition,
          defaultGrade: prefill.grade ?? _page.type.defaultGrade,
          defaultLocationId: prefill.locationId,
          defaultReadStatus: prefill.readStatus,
          defaultTags: prefill.tags,
        );
    _page.rebuild(_page.clearSelection);
    _page.invalidateShelf();
  }

  Future<void> bulkMoveToWishlistFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _page.selection.itemIds,
    );
    await _page.bulkActions().moveSelectedToWishlist(entries);
    _page.rebuild(_page.clearSelection);
    _page.invalidateShelf();
  }

  Future<void> bulkRemoveFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _page.selection.itemIds,
    );
    final confirmed = await _page.confirmBulkRemove(
      _page.context,
      count: entries.length,
      itemLabel: _page.type.pluralLabel.toLowerCase(),
    );
    if (!confirmed || !_page.mounted) return;
    await _page.bulkActions().removeSelected(entries);
    _page.rebuild(_page.clearSelection);
    _page.invalidateShelf();
  }

  Future<void> singleDuplicateFlow(LibraryProjectionItem item) async {
    if (item.source.ownedItem == null) return;
    await _page.bulkActions().duplicateSelected([item.source]);
    if (_page.mounted) {
      _page.invalidateShelf();
      ScaffoldMessenger.of(_page.context).showSnackBar(
        SnackBar(content: Text('Duplicated "${item.entry.title}"')),
      );
    }
  }

  Future<void> bulkDuplicateFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _page.selection.itemIds,
    );
    final confirmed = await showDialog<bool>(
      context: _page.context,
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
    if (confirmed != true || !_page.mounted) return;
    final count = await _page.bulkActions().duplicateSelected(entries);
    _page.rebuild(_page.clearSelection);
    _page.invalidateShelf();
    if (_page.mounted) {
      ScaffoldMessenger.of(_page.context).showSnackBar(
        SnackBar(
          content: Text('Duplicated $count item${count == 1 ? '' : 's'}'),
        ),
      );
    }
  }
}
