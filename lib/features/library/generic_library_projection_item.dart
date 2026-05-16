import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';

class GenericLibraryItem {
  const GenericLibraryItem({
    required this.source,
    required this.entry,
  });

  factory GenericLibraryItem.fromShelf(ShelfEntry source) {
    final item = source.catalogItem!;
    return GenericLibraryItem(
      source: source,
      entry: LibraryWorkspaceEntry(
        id: item.id,
        mediaType: item.kind,
        title: item.title,
        itemNumber: item.itemNumber,
        synopsis: item.synopsis,
        coverImageUrl: item.coverImageUrl,
        thumbnailImageUrl: item.thumbnailImageUrl,
        publisher: item.publisher,
        releaseDate: item.releaseDate,
        releaseYear: item.releaseYear,
        barcode: item.barcode,
        variant: item.displayEditionLabel,
        isOwned: source.isOwned,
        isWishlisted: source.isWishlisted,
        hasMissingCover: item.displayCoverUrl == null,
        hasMissingMetadata: genericHasMissingCoreMetadata(item),
        condition: source.ownedItem?.condition,
        grade: source.ownedItem?.grade,
        pricePaidCents: source.ownedItem?.pricePaidCents,
        currency: source.ownedItem?.currency,
        storageBox: source.ownedItem?.storageBox,
        updatedAt: source.updatedAt,
      ),
    );
  }

  final ShelfEntry source;
  final LibraryWorkspaceEntry entry;
}

List<GenericLibraryItem> genericItemsForShelf(
  ShelfState shelf,
  LibraryTypeConfig type,
) {
  final kind = type.workspace.kind;
  return [
    for (final source in shelf.entries)
      if (source.catalogItem != null && source.catalogItem!.kind == kind)
        GenericLibraryItem.fromShelf(source),
  ];
}

bool genericHasMissingCoreMetadata(CatalogItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
      item.barcode == null &&
      item.displayEditionLabel == null;
}
