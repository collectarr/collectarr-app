import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildMovieWorkWorkspaceEntry({
  required MovieWork work,
  required MoviePersonalOverlay overlay,
  List<ItemImage> itemImages = const <ItemImage>[],
}) {
  final common = _buildWorkEntryData(work, overlay, itemImages);
  return MovieWorkspaceEntry(
    common: common,
    series: work.series,
    publishing: work.publishingDetails,
    video: work.videoDetails,
  );
}

LibraryWorkspaceEntry buildMovieReleaseWorkspaceEntry({
  required MovieWork work,
  required MovieRelease release,
  required MoviePersonalOverlay overlay,
  List<ItemImage> itemImages = const <ItemImage>[],
}) {
  final common = _buildReleaseEntryData(
    work: work,
    release: release,
    overlay: overlay,
    itemImages: itemImages,
  );
  return MovieWorkspaceEntry(
    common: common,
    series: work.series,
    publishing: release.publishingDetails,
    video: release.videoDetails ?? work.videoDetails,
  );
}

LibraryWorkspaceEntry buildMoviesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  if (item == null) {
    throw StateError('Expected catalog item for movie workspace entry');
  }
  final work = MovieWork.fromMetadataItem(item);
  final overlay = MoviePersonalOverlay.fromShelfEntry(source);
  return buildMovieWorkWorkspaceEntry(
    work: work,
    overlay: overlay,
    itemImages: source.itemImages,
  );
}

LibraryWorkspaceEntry buildMoviesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final work = MovieWork.fromWorkspaceEntry(request.titleEntry);
  final release = MovieRelease.fromCatalogEdition(
    request.edition,
    workId: work.id,
  );
  final overlay = MoviePersonalOverlay(
    isOwnedOverride: request.isOwned,
    isTrackedOverride: request.isTracked,
    isWishlistedOverride: request.isWishlisted,
  );
  return buildMovieReleaseWorkspaceEntry(
    work: work,
    release: release,
    overlay: overlay,
    itemImages: request.titleEntry.itemImages,
  );
}

LibraryWorkspaceEntryData _buildWorkEntryData(
  MovieWork work,
  MoviePersonalOverlay overlay,
  List<ItemImage> itemImages,
) {
  final primaryRelease = work.releases.isEmpty ? null : work.releases.first;
  final edition = primaryRelease?.toCatalogEdition();
  return LibraryWorkspaceEntryData(
    id: work.id,
    browseScope: LibraryBrowserScope.title,
    titleItemId: work.id,
    releaseId: null,
    copyId: null,
    ownedItemId: overlay.ownedItem?.id,
    mediaType: 'movie',
    title: work.title,
    displayTitle: work.title,
    localizedTitle: null,
    originalTitle: work.originalTitle,
    searchAliases: null,
    itemNumber: null,
    synopsis: work.synopsis,
    coverImageUrl: work.coverImageUrl,
    thumbnailImageUrl: work.thumbnailImageUrl,
    frontCoverUrl: work.coverImageUrl,
    backCoverUrl: null,
    itemImages: itemImages,
    publisher: edition?.publisher ?? primaryRelease?.publisher,
    coverDate: work.releaseDate,
    releaseDate: work.releaseDate,
    releaseYear: work.releaseDate?.year,
    barcode: edition?.upc ?? primaryRelease?.barcode,
    variant: primaryRelease?.formatLabel,
    crossover: null,
    isOwned: overlay.isOwned,
    isTracked: overlay.isTracked,
    isWishlisted: overlay.isWishlisted,
    hasMissingCover: work.coverImageUrl == null && work.thumbnailImageUrl == null,
    hasMissingMetadata: work.hasMissingCoreMetadata,
    condition: overlay.ownedItem?.condition,
    grade: overlay.ownedItem?.grade,
    primaryReferenceLabel: null,
    referenceScopeLabel: null,
    referenceFormatLabel: primaryRelease?.formatLabel,
    referenceEditionId: primaryRelease?.id,
    referenceVariantId: null,
    referenceBundleReleaseId: null,
    notes: overlay.ownedItem?.personalNotes,
    tags: overlay.ownedItem?.tags,
    collectionStatus: overlay.ownedItem?.collectionStatus,
    lastBagBoardDate: overlay.ownedItem?.lastBagBoardDate,
    pricePaidCents: overlay.ownedItem?.pricePaidCents,
    currency: overlay.ownedItem?.currency,
    locationPath: overlay.locationPath,
    addedAt: overlay.ownedItem?.createdAt ?? overlay.wishlistItem?.createdAt,
    editions: [
      if (primaryRelease != null) primaryRelease.toCatalogEdition(),
      for (final release in work.releases.skip(1)) release.toCatalogEdition(),
    ],
    updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    trailerUrls: work.trailerUrls,
    plotSummary: work.synopsis,
    plotDescription: work.description,
    creators: work.contributions,
    characters: [
      for (final entry in work.characterAppearances)
        if (entry['name']?.toString().trim().isNotEmpty == true)
          entry['name'].toString().trim(),
    ],
    storyArcs: const <String>[],
    genres: const <String>[],
    country: null,
    language: work.originalLanguage,
    ageRating: work.ageRating,
    audienceRating: work.audienceRating,
    rawPlatforms: null,
  );
}

LibraryWorkspaceEntryData _buildReleaseEntryData({
  required MovieWork work,
  required MovieRelease release,
  required MoviePersonalOverlay overlay,
  required List<ItemImage> itemImages,
}) {
  final edition = release.toCatalogEdition();
  return LibraryWorkspaceEntryData(
    id: '${work.id}:release:${release.id}',
    browseScope: LibraryBrowserScope.release,
    titleItemId: work.id,
    releaseId: release.id,
    copyId: null,
    ownedItemId: overlay.ownedItem?.id,
    mediaType: 'movie',
    title: work.title,
    displayTitle: release.title ?? work.title,
    localizedTitle: null,
    originalTitle: work.originalTitle,
    searchAliases: null,
    itemNumber: release.media.isEmpty
        ? null
        : 'Disc ${release.media.first.discNumber ?? 1}',
    synopsis: work.synopsis,
    coverImageUrl: release.frontCoverUrl ?? work.coverImageUrl,
    thumbnailImageUrl: release.frontCoverUrl ??
        release.backCoverUrl ??
        work.thumbnailImageUrl ??
        work.coverImageUrl,
    frontCoverUrl: release.frontCoverUrl ?? work.coverImageUrl,
    backCoverUrl: release.backCoverUrl,
    itemImages: itemImages,
    publisher: release.publisher ?? release.distributor,
    coverDate: work.releaseDate,
    releaseDate: release.releaseDate,
    releaseYear: release.releaseDate?.year ?? work.releaseDate?.year,
    barcode: release.barcode,
    variant: release.formatLabel,
    crossover: null,
    isOwned: overlay.isOwned,
    isTracked: overlay.isTracked,
    isWishlisted: overlay.isWishlisted,
    hasMissingCover:
        release.frontCoverUrl == null && work.coverImageUrl == null,
    hasMissingMetadata: false,
    condition: overlay.ownedItem?.condition,
    grade: overlay.ownedItem?.grade,
    primaryReferenceLabel: null,
    referenceScopeLabel: null,
    referenceFormatLabel: release.formatLabel,
    referenceEditionId: release.id,
    referenceVariantId: null,
    referenceBundleReleaseId: null,
    notes: overlay.ownedItem?.personalNotes,
    tags: overlay.ownedItem?.tags,
    collectionStatus: overlay.ownedItem?.collectionStatus,
    lastBagBoardDate: overlay.ownedItem?.lastBagBoardDate,
    pricePaidCents: overlay.ownedItem?.pricePaidCents,
    currency: overlay.ownedItem?.currency,
    locationPath: overlay.locationPath,
    addedAt: overlay.ownedItem?.createdAt ?? overlay.wishlistItem?.createdAt,
    editions: [edition],
    updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    trailerUrls: release.trailerUrls,
    plotSummary: work.synopsis,
    plotDescription: work.description,
    creators: work.contributions,
    characters: [
      for (final entry in work.characterAppearances)
        if (entry['name']?.toString().trim().isNotEmpty == true)
          entry['name'].toString().trim(),
    ],
    storyArcs: const <String>[],
    genres: const <String>[],
    country: release.country,
    language: release.language ?? work.originalLanguage,
    ageRating: work.ageRating,
    audienceRating: work.audienceRating,
    rawPlatforms: null,
  );
}
