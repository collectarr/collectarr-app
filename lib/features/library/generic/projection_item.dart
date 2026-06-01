import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/shared/video_release_source.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_node.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';

class LibraryProjectionItem {
  const LibraryProjectionItem({
    required this.source,
    required this.entry,
    required this.node,
  });

  factory LibraryProjectionItem.fromShelf(ShelfEntry source) {
    final item = source.catalogItem!;
    final series = item.series;
    final video = item.video;
    final music = item.music;
    final game = item.game;
    final publishing = item.publishing;
    final resolvedEditions = resolveVideoCatalogEditionsForCatalogItem(
      item,
      ownedItems: source.ownedItem == null
        ? const <OwnedItem>[]
          : [source.ownedItem!],
      wishlistItems: source.wishlistItem == null
        ? const <WishlistItem>[]
          : [source.wishlistItem!],
    );
    final entry = LibraryWorkspaceEntry(
      id: item.id,
      browseScope: LibraryBrowserScope.title,
      titleItemId: item.id,
      ownedItemId: source.ownedItem?.id,
      mediaType: item.kind,
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      searchAliases: item.searchAliases,
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
      isTracked: source.isTracked,
      isWishlisted: source.isWishlisted,
      hasMissingCover: item.displayCoverUrl == null,
      hasMissingMetadata: genericHasMissingCoreMetadata(item),
      condition: source.ownedItem?.condition,
      grade: source.ownedItem?.grade,
      rawOrSlabbed: source.ownedItem?.rawOrSlabbed,
      gradingCompany: source.ownedItem?.gradingCompany,
      labelType: source.ownedItem?.labelType,
      certificationNumber: source.ownedItem?.certificationNumber,
      keyComic: source.ownedItem?.keyComic ?? false,
      keyReason: source.ownedItem?.keyReason,
      notes: source.ownedItem?.personalNotes ?? source.wishlistItem?.notes,
      tags: source.ownedItem?.tags,
      collectionStatus: source.ownedItem?.collectionStatus,
      lastBagBoardDate: source.ownedItem?.lastBagBoardDate,
      primaryReferenceLabel: libraryPrimaryReferenceLabel(
        ownedItem: source.ownedItem,
        wishlistItem: source.wishlistItem,
        mediaType: item.kind,
      ),
      referenceScopeLabel: libraryReferenceScopeLabel(
        ownedItem: source.ownedItem,
        wishlistItem: source.wishlistItem,
        mediaType: item.kind,
      ),
      referenceFormatLabel: libraryReferenceFormatLabel(
        ownedItem: source.ownedItem,
        wishlistItem: source.wishlistItem,
        editions: resolvedEditions,
        fallbackFormatLabel: item.physicalFormatLabel,
      ),
      referenceEditionId:
          source.ownedItem?.editionId ?? source.wishlistItem?.editionId,
      referenceVariantId:
          source.ownedItem?.variantId ?? source.wishlistItem?.variantId,
      referenceBundleReleaseId:
          source.ownedItem?.bundleReleaseId ?? source.wishlistItem?.bundleReleaseId,
      pricePaidCents: source.ownedItem?.pricePaidCents,
      currency: source.ownedItem?.currency,
      locationPath: source.locationPath,
      addedAt: source.ownedItem?.createdAt ?? source.wishlistItem?.createdAt,
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
      audienceRating: item.audienceRating,
      editions: resolvedEditions,
      updatedAt: source.updatedAt,
      trailerUrls: item.trailerUrls,
    );
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
        LibraryProjectionItem.fromShelf(source),
  ];
}

bool genericHasMissingCoreMetadata(CatalogItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
  item.displayCoverUrl == null &&
      item.displayEditionLabel == null;
}
