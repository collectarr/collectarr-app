import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/library/generic/metadata_refresh.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_compare_dialog.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:flutter/material.dart';

/// Handles metadata refresh, bulk metadata refresh, and
/// compare-with-server flows.
class LibraryPageMetadataCoordinator {
  const LibraryPageMetadataCoordinator(
    this._page, {
    required LibraryPageSelectedProjectionItemResolver
        selectedProjectionItemFor,
    required LibraryPageCanCompareMetadataWithServer
        canCompareMetadataWithServerItem,
  })  : _selectedProjectionItemFor = selectedProjectionItemFor,
        _canCompareMetadataWithServerItem = canCompareMetadataWithServerItem;

  final LibraryPageCoordinatorContext _page;
  final LibraryPageSelectedProjectionItemResolver _selectedProjectionItemFor;
  final LibraryPageCanCompareMetadataWithServer
      _canCompareMetadataWithServerItem;

  Future<void> showMetadataRefreshFlow(LibraryProjection? projection) async {
    if (projection == null) {
      ScaffoldMessenger.of(_page.context).showSnackBar(
        const SnackBar(content: Text('Library data is still loading')),
      );
      return;
    }
    final result = await showGenericLibraryMetadataRefreshDialog(
      context: _page.context,
      type: _page.type,
      accent: _page.accent,
      projection: projection,
    );
    if (result == null || !_page.mounted) return;
    _page.invalidateShelf();
    ScaffoldMessenger.of(_page.context).showSnackBar(
      SnackBar(
        content: Text(
          'Metadata refresh finished: ${result.matched}/${result.targets} matched, '
          '${result.cached} cached, ${result.failed} failed.',
        ),
      ),
    );
  }

  Future<void> bulkRefreshMetadataFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final selectedEntries = [
      for (final item in projection.filteredItems)
        if (_page.selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (selectedEntries.isEmpty) return;
    final result = await showLibraryMetadataRefreshDialog(
      context: _page.context,
      type: _page.type,
      accent: _page.accent,
      allEntries: selectedEntries,
      shownEntries: selectedEntries,
      selectedEntry: selectedEntries.first,
    );
    if (result == null || !_page.mounted) return;
    _page.rebuild(_page.clearSelection);
    _page.invalidateShelf();
    ScaffoldMessenger.of(_page.context).showSnackBar(
      SnackBar(
        content: Text(
          'Metadata refresh finished: ${result.matched}/${result.targets} matched, '
          '${result.cached} cached, ${result.failed} failed.',
        ),
      ),
    );
  }

  Future<void> compareMetadataWithServerFlow(
    LibraryProjection projection, {
    LibraryProjectionItem? item,
  }) async {
    if (!_page.type.kindUiAdapter.supportsMetadataCompareWithServer(
      _page.type,
    )) {
      return;
    }
    final targetItem = item ?? _selectedProjectionItemFor(projection);
    if (targetItem == null) {
      if (!_page.mounted) return;
      ScaffoldMessenger.of(_page.context).showSnackBar(
        const SnackBar(content: Text('Select an item first.')),
      );
      return;
    }
    if (!_canCompareMetadataWithServerItem(targetItem)) {
      if (!_page.mounted) return;
      ScaffoldMessenger.of(_page.context).showSnackBar(
        const SnackBar(
          content: Text(
            'This item cannot be compared with server metadata.',
          ),
        ),
      );
      return;
    }
    final localItem = targetItem.source.catalogItem;
    if (localItem == null) {
      if (!_page.mounted) return;
      ScaffoldMessenger.of(_page.context).showSnackBar(
        const SnackBar(content: Text('Missing local metadata for this item.')),
      );
      return;
    }
    await showLibraryMetadataCompareDialog(
      context: _page.context,
      localItem: localItem.toCatalogItem(),
      accent: _page.accent,
    );
  }

  /// Used by the video drilldown workspace to refresh a single title from Core.
  Future<void> refreshVideoTitleFromCore(LibraryProjectionItem item) async {
    final result = await showLibraryMetadataRefreshDialog(
      context: _page.context,
      type: _page.type,
      accent: _page.accent,
      allEntries: [item.entry],
      shownEntries: [item.entry],
      selectedEntry: item.entry,
    );
    if (result == null || !_page.mounted) return;
    _page.invalidateShelf();
    showAppToast(
      _page.context,
      'Metadata refresh finished: ${result.matched}/${result.targets} matched, '
      '${result.cached} cached, ${result.failed} failed.',
      tone: AppToastTone.success,
    );
  }
}
