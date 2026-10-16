import 'package:collectarr_app/features/library/reports/library_export_xml_flow.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
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

  void exportSelectedXmlFlow(LibraryProjection? projection) {
    if (projection == null) return;
    final entries = [
      for (final item in projection.allItems)
        if (_page.selection.itemIds.contains(item.target.id) &&
            item.source.libraryEntryRef != null)
          item.source.libraryEntryRef!
    ];
    exportLibraryEntriesXml(
        context: _page.context,
        type: _page.type,
        database: _page.ref.read(localDatabaseProvider),
        entries: entries);
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
