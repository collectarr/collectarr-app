import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/selection/context.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';

/// Handles the print / PDF report flow.
class LibraryPageReportCoordinator {
  const LibraryPageReportCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  Future<void> printSelectedReportFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final selected = LibrarySelectionContext.fromItems(
        projection.filteredItems, _page.selection.itemIds);
    final kind = selected.requireHomogeneous('This report');
    final type = libraryKindRegistrationForKind(kind);

    await printCollectionReport(
      context: _page.context,
      title: type.identity.title,
      items: projection.filteredItems
          .where((item) => item.source.mediaKind == kind)
          .toList(growable: false),
      type: type,
      allItems: projection.allItems
          .where((item) => item.source.mediaKind == kind)
          .toList(growable: false),
      selectedItemIds: _page.selection.itemIds,
    );
  }
}
