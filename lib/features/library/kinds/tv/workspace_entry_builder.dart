import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildTvWorkspaceEntry(
  TvSeries series,
  TvPersonalOverlay overlay,
) {
  return TvWorkspaceEntry(
    common: LibraryWorkspaceEntryData(
      id: series.id,
      browseScope: LibraryBrowserScope.title,
      titleItemId: series.id,
      releaseId: null,
      copyId: null,
      ownedItemId: overlay.ownedItem?.id,
      mediaType: 'tv',
      title: series.title,
      displayTitle: series.title,
      localizedTitle: null,
      originalTitle: series.originalTitle,
      searchAliases: const <String>[],
      itemNumber: null,
      synopsis: series.overview,
      coverImageUrl: series.posterUrl,
      thumbnailImageUrl: series.posterUrl ?? series.backdropUrl,
      itemImages: const <ItemImage>[],
      publisher: series.network,
      coverDate: series.firstAirDate,
      releaseDate: series.firstAirDate,
      releaseYear: series.firstAirDate?.year,
      barcode: null,
      variant: null,
      crossover: null,
      isOwned: overlay.isOwned,
      isTracked: overlay.isTracked,
      isWishlisted: overlay.isWishlisted,
      hasMissingCover: series.posterUrl == null,
      hasMissingMetadata: false,
      condition: null,
      grade: null,
      primaryReferenceLabel: null,
      referenceScopeLabel: null,
      referenceFormatLabel: null,
      referenceEditionId: null,
      referenceVariantId: null,
      referenceBundleReleaseId: null,
      notes: null,
      tags: null,
      collectionStatus: null,
      lastBagBoardDate: null,
      pricePaidCents: null,
      currency: null,
      locationPath: overlay.locationPath,
      addedAt: overlay.updatedAt,
      updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      editions: const <CatalogEdition>[],
      trailerUrls: const <TrailerLink>[],
      plotSummary: series.overview,
      plotDescription: null,
      creators: series.contributions,
      characters: const <String>[],
      storyArcs: const <String>[],
      genres: const <String>[],
      country: series.country,
      language: series.originalLanguage,
      ageRating: null,
      audienceRating: null,
      rawPlatforms: null,
    ),
    series: series.seriesDetails,
    publishing: series.publishingDetails,
    video: VideoCatalogDetails(runtimeMinutes: series.runtimeMinutes),
  );
}

LibraryWorkspaceEntry buildTvWorkspaceEntryFromShelf(ShelfEntry source) {
  final catalogItem = source.catalogItem;
  if (catalogItem == null) {
    throw StateError('Expected catalog item for TV workspace entry');
  }
  return buildTvWorkspaceEntry(
    TvSeries.fromMetadataItem(catalogItem),
    TvPersonalOverlay.fromShelf(source),
  );
}

LibraryWorkspaceEntry buildTvLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  final series = TvSeries(
    id: entry.titleItemId ?? entry.id,
    title: entry.title,
    originalTitle: entry.originalTitle,
    overview: entry.synopsis,
    firstAirDate: entry.releaseDate,
    lastAirDate: null,
    status: entry.collectionStatus,
    type: null,
    network: entry.publisher,
    originalLanguage: entry.language,
    country: entry.country,
    runtimeMinutes: entry.video?.runtimeMinutes,
    seriesDetails: entry.series,
    publishingDetails: entry.publishing,
    seasonCount: null,
    episodeCount: null,
    posterUrl: entry.coverImageUrl,
    backdropUrl: entry.thumbnailImageUrl,
    seasons: const <TvSeason>[],
    releases: const <TvRelease>[],
    media: const <TvReleaseMedia>[],
    releaseEpisodeMaps: const <TvReleaseEpisodeMap>[],
    contributions: entry.creators ?? const <Map<String, dynamic>>[],
    identifiers: const <Map<String, dynamic>>[],
    characterAppearances: entry.characters == null
        ? const <Map<String, dynamic>>[]
        : [
            for (final character in entry.characters!) {'name': character},
          ],
    metadata: const <String, dynamic>{},
  );
  final release = TvRelease.fromCatalogEdition(
    request.edition,
    seriesId: series.id,
  );
  return buildTvReleaseWorkspaceEntry(
    series: series,
    release: release,
    overlay: TvPersonalOverlay(
      updatedAt: request.updatedAt,
      isOwnedOverride: request.isOwned,
      isWishlistedOverride: request.isWishlisted,
      isTrackedOverride: request.isTracked,
    ),
  );
}

LibraryWorkspaceEntry buildTvSeriesWorkspaceEntry(
  TvSeries series,
  TvPersonalOverlay overlay,
) {
  return buildTvWorkspaceEntry(series, overlay);
}

LibraryWorkspaceEntry buildTvSeasonWorkspaceEntry({
  required TvSeries series,
  required TvSeason season,
  required TvPersonalOverlay overlay,
}) {
  final runtimeMinutes = season.episodes.fold<int>(
    0,
    (total, episode) => total + (episode.runtimeMinutes ?? 0),
  );
  return LibraryWorkspaceEntry(
    id: '${series.id}:season:${season.seasonNumber}',
    mediaType: 'tv',
    title: series.title,
    browseScope: LibraryBrowserScope.release,
    titleItemId: series.id,
    releaseId: season.id,
    displayTitle: season.title ?? series.title,
    originalTitle: season.originalTitle,
    itemNumber: 'Season ${season.seasonNumber}',
    synopsis: season.overview ?? series.overview,
    coverImageUrl: season.posterUrl ?? series.posterUrl,
    thumbnailImageUrl:
        season.posterUrl ?? series.posterUrl ?? series.backdropUrl,
    publisher: series.network,
    coverDate: season.airDate,
    releaseDate: season.airDate,
    releaseYear: season.airDate?.year,
    isOwned: overlay.isOwned,
    isTracked: overlay.isTracked,
    isWishlisted: overlay.isWishlisted,
    hasMissingCover: season.posterUrl == null && series.posterUrl == null,
    hasMissingMetadata: false,
    referenceScopeLabel: 'Season',
    referenceFormatLabel: 'Season ${season.seasonNumber}',
    referenceEditionId: season.id,
    locationPath: overlay.locationPath,
    addedAt: overlay.updatedAt,
    updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    editions: const <CatalogEdition>[],
    video: VideoCatalogDetails(
      runtimeMinutes: runtimeMinutes == 0 ? null : runtimeMinutes,
      nrDiscs: season.episodeCount,
    ),
    creators: series.contributions,
  );
}

LibraryWorkspaceEntry buildTvEpisodeWorkspaceEntry({
  required TvSeries series,
  required TvSeason season,
  required TvEpisode episode,
  required TvPersonalOverlay overlay,
}) {
  return LibraryWorkspaceEntry(
    id: '${series.id}:season:${season.seasonNumber}:episode:${episode.episodeNumber}',
    mediaType: 'tv',
    title: series.title,
    browseScope: LibraryBrowserScope.release,
    titleItemId: series.id,
    releaseId: episode.id,
    displayTitle: episode.title ?? season.title ?? series.title,
    originalTitle: episode.originalTitle,
    itemNumber: 'E${episode.episodeNumber.toString().padLeft(2, '0')}',
    synopsis: episode.overview ?? season.overview ?? series.overview,
    coverImageUrl: episode.stillUrl ?? season.posterUrl ?? series.posterUrl,
    thumbnailImageUrl: episode.stillUrl ??
        season.posterUrl ??
        series.posterUrl ??
        series.backdropUrl,
    publisher: series.network,
    coverDate: episode.airDate,
    releaseDate: episode.airDate,
    releaseYear: episode.airDate?.year,
    isOwned: overlay.isOwned,
    isTracked: overlay.isTracked,
    isWishlisted: overlay.isWishlisted,
    hasMissingCover: episode.stillUrl == null &&
        season.posterUrl == null &&
        series.posterUrl == null,
    hasMissingMetadata: false,
    locationPath: overlay.locationPath,
    addedAt: overlay.updatedAt,
    updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    editions: const <CatalogEdition>[],
    video: VideoCatalogDetails(runtimeMinutes: episode.runtimeMinutes),
    creators: series.contributions,
  );
}

LibraryWorkspaceEntry buildTvReleaseWorkspaceEntry({
  required TvSeries series,
  required TvRelease release,
  required TvPersonalOverlay overlay,
}) {
  final primaryMedia = release.media.isEmpty ? null : release.media.first;
  return LibraryWorkspaceEntry(
    id: '${series.id}:release:${release.id}',
    mediaType: 'tv',
    title: series.title,
    browseScope: LibraryBrowserScope.release,
    titleItemId: series.id,
    releaseId: release.id,
    displayTitle: release.title ?? series.title,
    originalTitle: series.originalTitle,
    itemNumber:
        primaryMedia == null ? null : 'Disc ${primaryMedia.discNumber ?? 1}',
    synopsis: series.overview,
    coverImageUrl: series.posterUrl,
    thumbnailImageUrl: series.posterUrl ?? series.backdropUrl,
    publisher: series.network,
    releaseDate: release.releaseDate,
    releaseYear: release.releaseDate?.year,
    barcode: null,
    variant: primaryMedia?.formatLabel ?? release.title,
    isOwned: overlay.isOwned,
    isTracked: overlay.isTracked,
    isWishlisted: overlay.isWishlisted,
    hasMissingCover: series.posterUrl == null,
    hasMissingMetadata: false,
    referenceEditionId: release.id,
    referenceVariantId: primaryMedia?.id,
    referenceFormatLabel: primaryMedia?.formatLabel,
    locationPath: overlay.locationPath,
    addedAt: overlay.updatedAt,
    updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    editions: const <CatalogEdition>[],
    video: VideoCatalogDetails(nrDiscs: release.media.length),
    creators: series.contributions,
  );
}

LibraryWorkspaceEntry buildTvReleaseMediaWorkspaceEntry({
  required TvRelease release,
  required TvReleaseMedia media,
}) {
  return LibraryWorkspaceEntry(
    id: '${release.id}:media:${media.id}',
    mediaType: 'tv',
    title: release.title ?? release.seriesId,
    browseScope: LibraryBrowserScope.release,
    titleItemId: release.seriesId,
    releaseId: release.id,
    displayTitle: media.title ?? release.title ?? release.seriesId,
    itemNumber: media.discNumber == null ? null : 'Disc ${media.discNumber}',
    variant: media.formatLabel,
    hasMissingCover: false,
    hasMissingMetadata: false,
    locationPath: null,
    addedAt: null,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    editions: const <CatalogEdition>[],
    video: VideoCatalogDetails(nrDiscs: media.discNumber),
  );
}

LibraryWorkspaceEntry buildTvReleaseEpisodeMapWorkspaceEntry({
  required TvRelease release,
  required TvReleaseMedia media,
  required TvReleaseEpisodeMap episodeMap,
}) {
  final sequence = episodeMap.sequenceNumber ?? episodeMap.discNumber ?? 1;
  return LibraryWorkspaceEntry(
    id: '${release.id}:media:${media.id}:map:${episodeMap.id}',
    mediaType: 'tv',
    title: release.title ?? release.seriesId,
    browseScope: LibraryBrowserScope.release,
    titleItemId: release.seriesId,
    releaseId: release.id,
    displayTitle: 'Episode map $sequence',
    itemNumber: 'Disc ${media.discNumber ?? sequence}',
    variant: media.formatLabel,
    hasMissingCover: false,
    hasMissingMetadata: false,
    locationPath: null,
    addedAt: null,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    editions: const <CatalogEdition>[],
    video: VideoCatalogDetails(nrDiscs: media.discNumber),
  );
}

List<LibraryWorkspaceEntry> buildTvReleaseWorkspaceEntries({
  required TvSeries series,
  required TvPersonalOverlay overlay,
}) {
  return [
    for (final release in series.releases)
      buildTvReleaseWorkspaceEntry(
        series: series,
        release: release,
        overlay: overlay,
      ),
  ];
}

TvWorkspaceNode buildTvSeriesWorkspaceNode({
  required String id,
  required String title,
}) {
  return TvWorkspaceNode(
    id: id,
    title: title,
    nodeType: TvWorkspaceNodeType.series,
  );
}
