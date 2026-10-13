import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';

/// Handles print / PDF report and missing-sequence flows.
class LibraryPageReportCoordinator {
  const LibraryPageReportCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  void printReportFlow(LibraryProjection projection) {
    printCollectionReport(
      context: _page.context,
      title: _page.type.identity.title,
      items: projection.filteredItems,
      type: _page.type,
      allItems: projection.allItems,
      selectedItemIds: _page.selection.itemIds,
    );
  }

  void printSelectedReportFlow(LibraryProjection? projection) {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    printCollectionReport(
      context: _page.context,
      title: _page.type.identity.title,
      items: projection.filteredItems,
      type: _page.type,
      allItems: projection.allItems,
      selectedItemIds: _page.selection.itemIds,
    );
  }

  Future<void> showMissingSequenceReportFlow(
    LibraryProjection projection,
  ) async {}
}
