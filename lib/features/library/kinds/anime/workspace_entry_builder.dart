import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_domain.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_mapper.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildAnimeLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  final work = item == null
      ? VideoCatalogItem(
          id: source.itemId,
          work: VideoWorkMetadata(
            title: source.itemId,
          ),
          technical: const VideoTechnicalMetadata(),
          releases: const [],
        )
      : VideoCatalogMapper.mapMetadataItemToVideo(item);
  final overlay = MoviePersonalOverlay(
    ownedItem: source.ownedItem,
    trackingEntry: source.trackingEntry,
    wishlistItem: source.wishlistItem,
    updatedAt: source.updatedAt,
  );
  return buildMovieWorkWorkspaceEntry(
    work: work,
    overlay: overlay,
    itemImages: source.itemImages,
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
