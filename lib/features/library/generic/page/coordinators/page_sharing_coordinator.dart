import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';

/// Handles share-to-clipboard / share-sheet flows.
class LibraryPageSharingCoordinator {
  const LibraryPageSharingCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  void shareCollectionFlow(LibraryProjection projection) {
    final items = projection.filteredItems.map((i) => i.entry).toList();
    showCollectionShareDialog(
      context: _page.context,
      title: _page.type.workspace.title,
      items: items,
    );
  }

  void shareSelectedCollectionFlow(LibraryProjection? projection) {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final items = [
      for (final item in projection.filteredItems)
        if (_page.selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (items.isEmpty) return;
    showCollectionShareDialog(
      context: _page.context,
      title: _page.type.workspace.title,
      items: items,
    );
  }
}
