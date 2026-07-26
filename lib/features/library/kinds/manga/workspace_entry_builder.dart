import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildMangaLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  final work = item == null
      ? BookWork(
          id: source.itemId,
          work: BookWorkMetadata(
            title: source.itemId,
          ),
          publishing: const BookPublishingMetadata(),
          releases: const [],
        )
      : BookCatalogMapper.mapMetadataItemToBook(item);
  final overlay = BookPersonalOverlay(
    ownedItem: source.ownedItem,
    trackingEntry: source.trackingEntry,
    wishlistItem: source.wishlistItem,
    locationPath: source.locationPath,
    watchSessions: source.watchSessions,
    itemImages: source.itemImages,
    updatedAt: source.updatedAt,
    fallbackOwnerLabel: source.fallbackOwnerLabel,
  );
  return buildBookWorkspaceEntry(work, overlay);
}

LibraryWorkspaceEntry buildMangaLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final titleEntry = request.titleEntry;
  return LibraryWorkspaceEntry.releaseNode(
    titleItemId: titleEntry.id,
    mediaType: 'manga',
    title: titleEntry.title,
    edition: request.edition,
    displayTitle: titleEntry.displayTitle,
    localizedTitle: titleEntry.localizedTitle,
    originalTitle: titleEntry.originalTitle,
    searchAliases: titleEntry.searchAliases,
    fallbackSynopsis: titleEntry.synopsis,
    fallbackCoverImageUrl: titleEntry.coverImageUrl,
    fallbackThumbnailImageUrl: titleEntry.thumbnailImageUrl,
    fallbackPublisher: titleEntry.publisher,
    fallbackCoverDate: titleEntry.coverDate,
    fallbackReleaseYear: titleEntry.releaseYear,
    fallbackCrossover: titleEntry.crossover,
    fallbackSeries: titleEntry.series,
    fallbackPublishing: titleEntry.publishing,
    fallbackCreators: titleEntry.creators,
    fallbackCharacters: titleEntry.characters,
    fallbackStoryArcs: titleEntry.storyArcs,
    fallbackGenres: titleEntry.genres,
    fallbackCountry: titleEntry.country,
    fallbackLanguage: titleEntry.language,
    fallbackAgeRating: titleEntry.ageRating,
    fallbackAudienceRating: titleEntry.audienceRating,
    isOwned: request.isOwned,
    isWishlisted: request.isWishlisted,
    isTracked: request.isTracked,
    referenceEditionId: request.referenceEditionId,
    referenceVariantId: request.referenceVariantId,
    referenceBundleReleaseId: request.referenceBundleReleaseId,
    editions: titleEntry.editions,
    updatedAt: request.updatedAt,
  );
}
