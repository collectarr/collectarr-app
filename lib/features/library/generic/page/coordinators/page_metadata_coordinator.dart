part of '../generic_library_page.dart';

/// Handles metadata refresh, bulk metadata refresh, and
/// compare-with-server flows.
class LibraryPageMetadataCoordinator {
  const LibraryPageMetadataCoordinator(this._s);

  final GenericLibraryPageState _s;

  Future<void> showMetadataRefreshFlow(LibraryProjection? projection) async {
    if (projection == null) {
      ScaffoldMessenger.of(_s.context).showSnackBar(
        const SnackBar(content: Text('Library data is still loading')),
      );
      return;
    }
    final result = await showGenericLibraryMetadataRefreshDialog(
      context: _s.context,
      type: _s.widget.type,
      accent: _s.widget.accent,
      projection: projection,
    );
    if (result == null || !_s.mounted) return;
    _s.ref.invalidate(shelfProvider);
    ScaffoldMessenger.of(_s.context).showSnackBar(
      SnackBar(
        content: Text(
          'Metadata refresh finished: ${result.matched}/${result.targets} matched, '
          '${result.cached} cached, ${result.failed} failed.',
        ),
      ),
    );
  }

  Future<void> bulkRefreshMetadataFlow(LibraryProjection? projection) async {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final selectedEntries = <LibraryWorkspaceEntry>[
      for (final item in projection.filteredItems)
        if (_s._selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (selectedEntries.isEmpty) return;
    final result = await showLibraryMetadataRefreshDialog(
      context: _s.context,
      type: _s.widget.type,
      accent: _s.widget.accent,
      allEntries: selectedEntries,
      shownEntries: selectedEntries,
      selectedEntry: selectedEntries.first,
    );
    if (result == null || !_s.mounted) return;
    _s._rebuild(() => _s._selection = _s._selection.clear());
    _s.ref.invalidate(shelfProvider);
    ScaffoldMessenger.of(_s.context).showSnackBar(
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
    if (!_s.widget.type.kindUiAdapter.supportsMetadataCompareWithServer(
      _s.widget.type,
    )) {
      return;
    }
    final targetItem =
        item ?? _s._collectionActionCoordinator.selectedProjectionItemFor(projection);
    if (targetItem == null) {
      if (!_s.mounted) return;
      ScaffoldMessenger.of(_s.context).showSnackBar(
        const SnackBar(content: Text('Select an item first.')),
      );
      return;
    }
    if (!_s._collectionActionCoordinator.canCompareMetadataWithServerItem(
      targetItem,
    )) {
      if (!_s.mounted) return;
      ScaffoldMessenger.of(_s.context).showSnackBar(
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
      if (!_s.mounted) return;
      ScaffoldMessenger.of(_s.context).showSnackBar(
        const SnackBar(content: Text('Missing local metadata for this item.')),
      );
      return;
    }
    await showLibraryMetadataCompareDialog(
      context: _s.context,
      localItem: localItem.toCatalogItem(),
      accent: _s.widget.accent,
    );
  }

  /// Used by the video drilldown workspace to refresh a single title from Core.
  Future<void> refreshVideoTitleFromCore(LibraryProjectionItem item) async {
    final result = await showLibraryMetadataRefreshDialog(
      context: _s.context,
      type: _s.widget.type,
      accent: _s.widget.accent,
      allEntries: [item.entry],
      shownEntries: [item.entry],
      selectedEntry: item.entry,
    );
    if (result == null || !_s.mounted) return;
    _s.ref.invalidate(shelfProvider);
    showAppToast(
      _s.context,
      'Metadata refresh finished: ${result.matched}/${result.targets} matched, '
      '${result.cached} cached, ${result.failed} failed.',
      tone: AppToastTone.success,
    );
  }
}
