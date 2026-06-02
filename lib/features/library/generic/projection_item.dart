import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_node.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class LibraryProjectionItem {
  const LibraryProjectionItem({
    required this.source,
    required this.entry,
    required this.node,
  });

  factory LibraryProjectionItem.fromShelf(
    ShelfEntry source,
    LibraryTypeConfig type,
  ) {
    final item = source.catalogItem!;
    final entry = type.presentation.workspaceEntryBuilder(source);
    return LibraryProjectionItem(
      source: source,
      entry: entry,
      node: LibraryBrowserNode(
        id: item.id,
        scope: LibraryBrowserScope.title,
        entry: entry,
        titleItemId: item.id,
        catalogItem: item,
        source: source,
      ),
    );
  }

  final ShelfEntry source;
  final LibraryWorkspaceEntry entry;
  final LibraryBrowserNode node;
}

List<LibraryProjectionItem> libraryItemsForShelf(
  ShelfState shelf,
  LibraryTypeConfig type,
) {
  final kind = type.workspace.kind;
  return [
    for (final source in shelf.entries)
      if (source.catalogItem != null && source.catalogItem!.kind == kind.apiValue)
        LibraryProjectionItem.fromShelf(source, type),
  ];
}
