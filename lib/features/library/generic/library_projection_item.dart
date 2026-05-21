import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';

class LibraryProjectionItem {
  const LibraryProjectionItem({
    required this.source,
    required this.entry,
  });

  factory LibraryProjectionItem.fromShelf(ShelfEntry source) {
    final item = source.catalogItem!;
    return LibraryProjectionItem(
      source: source,
      entry: LibraryWorkspaceEntry(
        id: item.id,
        ownedItemId: source.ownedItem?.id,
        mediaType: item.kind,
        title: item.title,
        seriesId: item.seriesId,
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
        seriesTitle: item.seriesTitle,
        volumeName: item.volumeName,
        volumeNumber: item.volumeNumber,
        seasonNumber: item.seasonNumber,
        episodeNumber: item.episodeNumber,
        trackCount: item.trackCount,
        tracks: item.tracks,
        creators: item.creators,
        characters: item.characters,
        storyArcs: item.storyArcs,
        genres: item.genres,
        pageCount: item.pageCount,
        coverPriceCents: item.coverPriceCents,
        catalogCurrency: item.currency,
        country: item.country,
        language: item.language,
        ageRating: item.ageRating,
        imprint: item.imprint,
        subtitle: item.subtitle,
        seriesGroup: item.seriesGroup,
        updatedAt: source.updatedAt,
      ),
    );
  }

  final ShelfEntry source;
  final LibraryWorkspaceEntry entry;
}

List<LibraryProjectionItem> libraryItemsForShelf(
  ShelfState shelf,
  LibraryTypeConfig type,
) {
  final kind = type.workspace.kind;
  return [
    for (final source in shelf.entries)
      if (source.catalogItem != null && source.catalogItem!.kind == kind)
        LibraryProjectionItem.fromShelf(source),
  ];
}

bool genericHasMissingCoreMetadata(CatalogItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
      item.barcode == null &&
      item.displayEditionLabel == null;
}
