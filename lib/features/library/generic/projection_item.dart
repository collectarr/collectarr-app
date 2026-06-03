import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/video/video_release_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
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
{  LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
  String? releaseFolderTitleItemId,
}) {
  final kind = type.workspace.kind;
  if (browserMode == LibraryWorkspaceBrowserMode.releases) {
    return _libraryReleaseItemsForShelf(
      shelf,
      type,
      releaseFolderTitleItemId: releaseFolderTitleItemId,
    );
  }
  return [
    for (final source in shelf.entries)
      if (source.catalogItem != null && source.catalogItem!.kind == kind.apiValue)
        LibraryProjectionItem.fromShelf(source, type),
  ];
}

List<LibraryProjectionItem> _libraryReleaseItemsForShelf(
  ShelfState shelf,
  LibraryTypeConfig type, {
  String? releaseFolderTitleItemId,
}) {
  final kind = type.workspace.kind;
  final requestedTitleId = releaseFolderTitleItemId?.trim();
  final items = <LibraryProjectionItem>[];

  for (final source in shelf.entries) {
    final catalogItem = source.catalogItem;
    if (catalogItem == null || catalogItem.kind != kind.apiValue) {
      continue;
    }
    if (requestedTitleId != null && catalogItem.id != requestedTitleId) {
      continue;
    }

    final titleEntry = type.presentation.workspaceEntryBuilder(source);
    final resolvedEditions = resolveVideoCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: source.ownedItem == null
          ? const []
          : [source.ownedItem!],
      wishlistItems: source.wishlistItem == null
          ? const []
          : [source.wishlistItem!],
    );
    if (resolvedEditions.isEmpty) {
      // Hide media that have no release-level data in release mode.
      continue;
    }

    for (final edition in resolvedEditions) {
      final ownedMatches = source.ownedItem == null
          ? false
          : matchesVideoReleaseAnchor(
              edition,
              editionId: source.ownedItem!.editionId,
              variantId: source.ownedItem!.variantId,
              bundleReleaseId: source.ownedItem!.bundleReleaseId,
            );
      final wishlistMatches = source.wishlistItem == null
          ? false
          : matchesVideoReleaseAnchor(
              edition,
              editionId: source.wishlistItem!.editionId,
              variantId: source.wishlistItem!.variantId,
              bundleReleaseId: source.wishlistItem!.bundleReleaseId,
            );

      final entry = type.presentation.releaseEntryBuilder(
        LibraryReleaseEntryRequest(
          titleEntry: titleEntry,
          edition: edition,
          isOwned: ownedMatches,
          isWishlisted: wishlistMatches,
          isTracked: source.isTracked,
          referenceEditionId: edition.id,
          referenceVariantId: preferredVideoEditionVariantId(edition),
          editions: resolvedEditions,
          updatedAt: source.updatedAt,
        ),
      );
      items.add(
        LibraryProjectionItem(
          source: source,
          entry: entry,
          node: LibraryBrowserNode(
            id: entry.id,
            scope: entry.browseScope,
            entry: entry,
            titleItemId: titleEntry.id,
            releaseId: edition.id,
            edition: edition,
            source: source,
          ),
        ),
      );
    }
  }
  return items;
}
