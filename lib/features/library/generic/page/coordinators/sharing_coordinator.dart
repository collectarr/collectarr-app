import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/selection/context.dart';
import 'package:collectarr_app/features/library/reports/export_xml_flow.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/reports/collection_export_csv_txt.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';

/// Handles share-to-clipboard / share-sheet and CSV/TXT export flows.
class LibraryPageSharingCoordinator {
  const LibraryPageSharingCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  Future<void> exportSelectedCsvTxtFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final selected = LibrarySelectionContext.fromItems(
        projection.filteredItems, _page.selection.itemIds);
    final kind = selected.requireHomogeneous('This report');
    final type = libraryKindRegistrationForKind(kind);

    await exportCollectionCsvTxt(
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

  Future<void> exportSelectedXmlFlow(LibraryProjection? projection) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final selected = LibrarySelectionContext.fromItems(
        projection.filteredItems, _page.selection.itemIds);
    final kind = selected.requireHomogeneous('This report');
    final type = libraryKindRegistrationForKind(kind);

    selected.requireEvery(
        'Export XML', (entry) => entry.libraryEntryRef != null);
    final entries = [
      for (final entry in selected.entries) entry.libraryEntryRef!
    ];
    await exportLibraryEntriesXml(
        context: _page.context,
        type: type,
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
}
