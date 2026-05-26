import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';

class LibraryBrowserNode {
  const LibraryBrowserNode({
    required this.id,
    required this.scope,
    required this.entry,
    required this.titleItemId,
    this.releaseId,
    this.copyId,
    this.catalogItem,
    this.edition,
    this.source,
  });

  final String id;
  final LibraryBrowserScope scope;
  final String titleItemId;
  final String? releaseId;
  final String? copyId;
  final LibraryWorkspaceEntry entry;
  final CatalogItem? catalogItem;
  final CatalogEdition? edition;
  final ShelfEntry? source;
}