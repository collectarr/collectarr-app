import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildMangaLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  final work = item == null
      ? MangaWork(
          id: source.itemId,
          title: source.itemId,
        )
      : MangaWork.fromMetadataItem(item);
  final overlay = MangaPersonalOverlay.fromShelf(source);
  return LibraryWorkspaceEntry(
    id: work.id,
    mediaType: 'manga',
    title: work.title,
    browseScope: LibraryBrowserScope.title,
    titleItemId: work.id,
    ownedItemId: source.ownedItem?.id,
    displayTitle: work.displayTitle,
    localizedTitle: work.localizedTitle,
    originalTitle: work.originalTitle,
    searchAliases: _copyStringList(work.searchAliases),
    itemNumber: work.itemNumber,
    synopsis: work.synopsis,
    coverImageUrl: work.coverImageUrl,
    thumbnailImageUrl: work.thumbnailImageUrl,
    itemImages: source.itemImages,
    publisher: work.publisher,
    coverDate: work.coverDate,
    releaseDate: work.releaseDate,
    releaseYear: work.releaseYear,
    barcode: work.barcode,
    variant: work.displayEditionLabel,
    crossover: work.crossover,
    isOwned: source.isOwned,
    isTracked: source.isTracked,
    isWishlisted: source.isWishlisted,
    hasMissingCover: work.displayCoverUrl == null,
    hasMissingMetadata: work.hasMissingCoreMetadata,
    condition: overlay.ownedItem?.condition,
    grade: overlay.ownedItem?.grade,
    signedBy: overlay.ownedItem?.signedBy,
    marketValueCents: overlay.ownedItem?.marketValueCents,
    marketValueCurrency: overlay.ownedItem?.currency,
    primaryReferenceLabel: libraryPrimaryReferenceLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      mediaType: 'manga',
    ),
    referenceScopeLabel: libraryReferenceScopeLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      mediaType: 'manga',
    ),
    referenceFormatLabel: libraryReferenceFormatLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      editions: work.chapters.map((chapter) => chapter.toCatalogEdition()).toList(
        growable: false,
      ),
      fallbackFormatLabel: work.publishing?.subtitle ?? work.subtitle,
    ),
    referenceEditionId:
        source.ownedItem?.editionId ?? source.wishlistItem?.editionId,
    referenceVariantId:
        source.ownedItem?.variantId ?? source.wishlistItem?.variantId,
    referenceBundleReleaseId:
        source.ownedItem?.bundleReleaseId ?? source.wishlistItem?.bundleReleaseId,
    notes: overlay.ownedItem?.personalNotes ?? overlay.wishlistItem?.notes,
    tags: overlay.ownedItem?.tags,
    collectionStatus: overlay.ownedItem?.collectionStatus,
    lastBagBoardDate: overlay.lastBagBoardDate,
    pricePaidCents: overlay.ownedItem?.pricePaidCents,
    currency: overlay.ownedItem?.currency,
    locationPath: overlay.locationPath,
    addedAt: overlay.ownedItem?.createdAt ?? overlay.wishlistItem?.createdAt,
    editions: work.chapters.map((chapter) => chapter.toCatalogEdition()).toList(
      growable: false,
    ),
    updatedAt: source.updatedAt,
    trailerUrls: work.trailerUrls,
    plotSummary: work.plotSummary ?? work.synopsis,
    plotDescription: work.plotDescription,
    creators: work.creators,
    characters: work.characters,
    storyArcs: work.storyArcs,
    genres: work.genres,
    country: work.country,
    language: work.language ?? work.originalLanguage,
    ageRating: work.ageRating,
    audienceRating: work.audienceRating,
    series: work.series,
    publishing: work.publishing,
  );
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

List<String>? _copyStringList(List<String>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return List<String>.unmodifiable(values);
}
