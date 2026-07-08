part of '../generic_library_page.dart';

/// Handles share-to-clipboard / share-sheet flows.
class LibraryPageSharingCoordinator {
  const LibraryPageSharingCoordinator(this._s);

  final GenericLibraryPageState _s;

  void shareCollectionFlow(LibraryProjection projection) {
    final items = projection.filteredItems.map((i) => i.entry).toList();
    showCollectionShareDialog(
      context: _s.context,
      title: _s.widget.type.workspace.title,
      items: items,
    );
  }

  void shareSelectedCollectionFlow(LibraryProjection? projection) {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final items = [
      for (final item in projection.filteredItems)
        if (_s._selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (items.isEmpty) return;
    showCollectionShareDialog(
      context: _s.context,
      title: _s.widget.type.workspace.title,
      items: items,
    );
  }
}
