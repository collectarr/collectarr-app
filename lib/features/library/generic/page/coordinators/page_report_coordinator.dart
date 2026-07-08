import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/shared/comic/missing_comics_dialog.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';

/// Handles print / PDF report and missing-comics flows.
class LibraryPageReportCoordinator {
  const LibraryPageReportCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  void printReportFlow(LibraryProjection projection) {
    final items = projection.filteredItems.map((i) => i.entry).toList();
    printCollectionReport(
      context: _page.context,
      title: _page.type.workspace.title,
      items: items,
    );
  }

  void printSelectedReportFlow(LibraryProjection? projection) {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final items = [
      for (final item in projection.filteredItems)
        if (_page.selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (items.isEmpty) return;
    printCollectionReport(
      context: _page.context,
      title: _page.type.workspace.title,
      items: items,
    );
  }

  Future<void> showMissingComicsFlow(LibraryProjection projection) async {
    await showComicMissingComicsDialog(
      context: _page.context,
      type: _page.type,
      projection: projection,
      accent: _page.accent,
    );
  }
}
