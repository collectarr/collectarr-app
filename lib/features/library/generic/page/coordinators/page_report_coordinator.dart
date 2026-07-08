part of '../generic_library_page.dart';

/// Handles print / PDF report and missing-comics flows.
class LibraryPageReportCoordinator {
  const LibraryPageReportCoordinator(this._s);

  final GenericLibraryPageState _s;

  void printReportFlow(LibraryProjection projection) {
    final items = projection.filteredItems.map((i) => i.entry).toList();
    printCollectionReport(
      context: _s.context,
      title: _s.widget.type.workspace.title,
      items: items,
    );
  }

  void printSelectedReportFlow(LibraryProjection? projection) {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final items = [
      for (final item in projection.filteredItems)
        if (_s._selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (items.isEmpty) return;
    printCollectionReport(
      context: _s.context,
      title: _s.widget.type.workspace.title,
      items: items,
    );
  }

  Future<void> showMissingComicsFlow(LibraryProjection projection) async {
    await showComicMissingComicsDialog(
      context: _s.context,
      type: _s.widget.type,
      projection: projection,
      accent: _s.widget.accent,
    );
  }
}
