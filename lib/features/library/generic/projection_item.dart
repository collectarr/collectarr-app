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
    final series = item.series;
    final video = item.video;
    final music = item.music;
    final game = item.game;
    final publishing = item.publishing;
    return LibraryProjectionItem(
      source: source,
      entry: LibraryWorkspaceEntry(
        id: item.id,
        ownedItemId: source.ownedItem?.id,
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
        rawOrSlabbed: source.ownedItem?.rawOrSlabbed,
        gradingCompany: source.ownedItem?.gradingCompany,
        keyComic: source.ownedItem?.keyComic ?? false,
        keyReason: source.ownedItem?.keyReason,
        notes: source.ownedItem?.personalNotes ?? source.wishlistItem?.notes,
        pricePaidCents: source.ownedItem?.pricePaidCents,
        currency: source.ownedItem?.currency,
        storageBox: source.locationPath ?? source.ownedItem?.storageBox,
        series: series,
        video: video,
        music: music,
        game: game,
        publishing: publishing,
        creators: item.creators,
        characters: item.characters,
        storyArcs: item.storyArcs,
        genres: item.genres,
        country: item.country,
        language: item.language,
        ageRating: item.ageRating,
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
