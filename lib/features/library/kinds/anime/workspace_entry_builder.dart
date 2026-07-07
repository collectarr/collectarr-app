import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildAnimeLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  final series = item == null
      ? AnimeSeries(
          id: source.itemId,
          title: source.itemId,
        )
      : AnimeSeries.fromMetadataItem(item);
  final overlay = AnimePersonalOverlay.fromShelf(source);
  return LibraryWorkspaceEntry(
    id: series.id,
    mediaType: 'anime',
    title: series.title,
    browseScope: LibraryBrowserScope.title,
    titleItemId: series.id,
    ownedItemId: source.ownedItem?.id,
    displayTitle: series.displayTitle,
    localizedTitle: series.localizedTitle,
    originalTitle: series.originalTitle,
    searchAliases: _copyStringList(series.searchAliases),
    itemNumber: series.itemNumber,
    synopsis: series.synopsis,
    coverImageUrl: series.coverImageUrl,
    thumbnailImageUrl: series.thumbnailImageUrl,
    itemImages: source.itemImages,
    publisher: series.publisher,
    coverDate: series.coverDate,
    releaseDate: series.releaseDate,
    releaseYear: series.releaseYear,
    barcode: series.barcode,
    variant: series.displayEpisodeLabel,
    crossover: series.crossover,
    isOwned: source.isOwned,
    isTracked: source.isTracked,
    isWishlisted: source.isWishlisted,
    hasMissingCover: series.displayCoverUrl == null,
    hasMissingMetadata: series.hasMissingCoreMetadata,
    condition: overlay.ownedItem?.condition,
    grade: overlay.ownedItem?.grade,
    primaryReferenceLabel: libraryPrimaryReferenceLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      mediaType: 'anime',
    ),
    referenceScopeLabel: libraryReferenceScopeLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      mediaType: 'anime',
    ),
    referenceFormatLabel: libraryReferenceFormatLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      editions: series.episodes.map((episode) => episode.toCatalogEdition()).toList(
        growable: false,
      ),
      fallbackFormatLabel: series.video?.screenRatio,
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
    lastBagBoardDate: overlay.ownedItem?.lastBagBoardDate,
    pricePaidCents: overlay.ownedItem?.pricePaidCents,
    currency: overlay.ownedItem?.currency,
    locationPath: overlay.locationPath,
    addedAt: overlay.ownedItem?.createdAt ?? overlay.wishlistItem?.createdAt,
    editions: series.episodes.map((episode) => episode.toCatalogEdition()).toList(
      growable: false,
    ),
    updatedAt: source.updatedAt,
    trailerUrls: series.trailerUrls,
    plotSummary: series.plotSummary ?? series.synopsis,
    plotDescription: series.plotDescription,
    creators: series.creators,
    characters: series.characters,
    storyArcs: series.storyArcs,
    genres: series.genres,
    country: series.country,
    language: series.language ?? series.originalLanguage,
    ageRating: series.ageRating,
    audienceRating: series.audienceRating,
    series: series.series,
    video: series.video,
  );
}

LibraryWorkspaceEntry buildAnimeLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final titleEntry = request.titleEntry;
  return LibraryWorkspaceEntry.releaseNode(
    titleItemId: titleEntry.id,
    mediaType: 'anime',
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
    fallbackVideo: titleEntry.video,
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
