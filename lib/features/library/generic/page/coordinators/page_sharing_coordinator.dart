import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/reports/collection_export_csv_txt.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';

/// Handles share-to-clipboard / share-sheet and CSV/TXT export flows.
class LibraryPageSharingCoordinator {
  const LibraryPageSharingCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  void exportCsvTxtFlow(LibraryProjection projection) {
    exportCollectionCsvTxt(
      context: _page.context,
      title: _page.type.identity.title,
      items: projection.filteredItems,
      type: _page.type,
      allItems: projection.allItems,
      selectedItemIds: _page.selection.itemIds,
    );
  }

  void exportSelectedCsvTxtFlow(LibraryProjection? projection) {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    exportCollectionCsvTxt(
      context: _page.context,
      title: _page.type.identity.title,
      items: projection.filteredItems,
      type: _page.type,
      allItems: projection.allItems,
      selectedItemIds: _page.selection.itemIds,
    );
  }

  void shareCollectionFlow(LibraryProjection projection) {
    final items = projection.filteredItems;
    showCollectionShareDialog(
      context: _page.context,
      title: _page.type.identity.title,
      items: items,
    );
  }

  void shareSelectedCollectionFlow(LibraryProjection? projection) {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final items = [
      for (final item in projection.filteredItems)
        if (_page.selection.itemIds.contains(item.target.id)) item,
    ];
    if (items.isEmpty) return;
    showCollectionShareDialog(
      context: _page.context,
      title: _page.type.identity.title,
      items: items,
    );
  }
}
