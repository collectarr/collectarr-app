import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildTvSeriesWorkspaceEntry(
  TvSeries series,
  TvPersonalOverlay overlay,
) {
  return LibraryWorkspaceEntry(
    id: series.id,
    mediaType: 'tv',
    title: series.title,
    browseScope: LibraryBrowserScope.title,
    titleItemId: series.id,
    displayTitle: series.title,
    originalTitle: series.originalTitle,
    synopsis: series.overview,
    coverImageUrl: series.posterUrl,
    thumbnailImageUrl: series.posterUrl ?? series.backdropUrl,
    publisher: series.network,
    coverDate: series.firstAirDate,
    releaseDate: series.firstAirDate,
    releaseYear: series.firstAirDate?.year,
    isOwned: overlay.isOwned,
    isTracked: overlay.isTracked,
    isWishlisted: overlay.isWishlisted,
    hasMissingCover: series.posterUrl == null,
    hasMissingMetadata: false,
    locationPath: overlay.locationPath,
    addedAt: overlay.updatedAt,
    updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    editions: const <CatalogEdition>[],
    video: VideoCatalogDetails(runtimeMinutes: series.runtimeMinutes),
    creators: series.contributions,
  );
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
    thumbnailImageUrl: season.posterUrl ?? series.posterUrl ?? series.backdropUrl,
    publisher: series.network,
    coverDate: season.airDate,
    releaseDate: season.airDate,
    releaseYear: season.airDate?.year,
    isOwned: overlay.isOwned,
    isTracked: overlay.isTracked,
    isWishlisted: overlay.isWishlisted,
    hasMissingCover: season.posterUrl == null && series.posterUrl == null,
    hasMissingMetadata: false,
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
    thumbnailImageUrl:
        episode.stillUrl ?? season.posterUrl ?? series.posterUrl ?? series.backdropUrl,
    publisher: series.network,
    coverDate: episode.airDate,
    releaseDate: episode.airDate,
    releaseYear: episode.airDate?.year,
    isOwned: overlay.isOwned,
    isTracked: overlay.isTracked,
    isWishlisted: overlay.isWishlisted,
    hasMissingCover:
        episode.stillUrl == null && season.posterUrl == null && series.posterUrl == null,
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
    itemNumber: primaryMedia == null ? null : 'Disc ${primaryMedia.discNumber ?? 1}',
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

LibraryWorkspaceEntry buildTvReleaseMediaWorkspaceEntry({
  required TvRelease release,
  required TvReleaseMedia media,
}) {
  return LibraryWorkspaceEntry(
    id: '${release.id}:media:${media.id}',
    mediaType: 'tv',
    title: release.title ?? 'TV release',
    browseScope: LibraryBrowserScope.release,
    titleItemId: release.seriesId,
    releaseId: release.id,
    displayTitle: media.title ?? release.title ?? 'Disc ${media.discNumber ?? 1}',
    originalTitle: release.title,
    itemNumber: media.discNumber == null ? null : 'Disc ${media.discNumber}',
    synopsis: null,
    coverImageUrl: null,
    thumbnailImageUrl: null,
    publisher: null,
    releaseDate: release.releaseDate,
    releaseYear: release.releaseDate?.year,
    barcode: null,
    variant: media.formatLabel ?? media.title,
    isOwned: false,
    isTracked: false,
    isWishlisted: false,
    hasMissingCover: true,
    hasMissingMetadata: false,
    referenceEditionId: release.id,
    referenceVariantId: media.id,
    referenceFormatLabel: media.formatLabel,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    editions: const <CatalogEdition>[],
    video: VideoCatalogDetails(
      nrDiscs: 1,
      runtimeMinutes: media.episodes.fold<int>(
        0,
        (total, episode) => total + (episode.runtimeMinutes ?? 0),
      ),
    ),
    creators: const <Map<String, dynamic>>[],
  );
}

LibraryWorkspaceEntry buildTvReleaseEpisodeMapWorkspaceEntry({
  required TvRelease release,
  required TvReleaseMedia media,
  required TvReleaseEpisodeMap episodeMap,
}) {
  return LibraryWorkspaceEntry(
    id: '${release.id}:media:${media.id}:map:${episodeMap.id}',
    mediaType: 'tv',
    title: release.title ?? 'TV release',
    browseScope: LibraryBrowserScope.release,
    titleItemId: release.seriesId,
    releaseId: release.id,
    displayTitle: 'Episode map ${episodeMap.sequenceNumber ?? episodeMap.discNumber ?? 1}',
    originalTitle: media.title ?? release.title,
    itemNumber: episodeMap.discNumber == null ? null : 'Disc ${episodeMap.discNumber}',
    synopsis: null,
    coverImageUrl: null,
    thumbnailImageUrl: null,
    publisher: null,
    releaseDate: release.releaseDate,
    releaseYear: release.releaseDate?.year,
    barcode: null,
    variant: media.formatLabel ?? media.title,
    isOwned: false,
    isTracked: false,
    isWishlisted: false,
    hasMissingCover: true,
    hasMissingMetadata: false,
    referenceEditionId: release.id,
    referenceVariantId: media.id,
    referenceFormatLabel: media.formatLabel,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    editions: const <CatalogEdition>[],
    video: VideoCatalogDetails(
      nrDiscs: 1,
      runtimeMinutes: null,
    ),
    creators: const <Map<String, dynamic>>[],
  );
}

LibraryWorkspaceEntry buildTvLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  if (item == null) {
    return LibraryWorkspaceEntry(
      id: '',
      mediaType: 'tv',
      title: '',
      updatedAt: source.updatedAt,
    );
  }
  final series = _seriesFromLibraryMetadataItem(item);
  return buildTvSeriesWorkspaceEntry(
    series,
    TvPersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      updatedAt: source.updatedAt,
    ),
  );
}

LibraryWorkspaceEntry buildTvLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final series = _seriesFromWorkspaceEntry(request.titleEntry);
  final release = _releaseFromRequest(request);
  return buildTvReleaseWorkspaceEntry(
    series: series,
    release: release,
    overlay: TvPersonalOverlay(
      isOwnedOverride: request.isOwned,
      isTrackedOverride: request.isTracked,
      isWishlistedOverride: request.isWishlisted,
      updatedAt: request.updatedAt,
    ),
  );
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

TvSeries _seriesFromLibraryMetadataItem(LibraryMetadataItem item) {
  return TvSeries(
    id: item.id,
    title: item.title,
    originalTitle: item.originalTitle,
    overview: item.synopsis,
    firstAirDate: item.releaseDate,
    lastAirDate: item.releaseDate,
    status: item.series?.seriesTitle == null ? null : 'Released',
    type: item.mediaKind.apiValue,
    network: item.publisher,
    originalLanguage: item.language,
    country: item.country,
    runtimeMinutes: item.video?.runtimeMinutes,
    seasonCount: null,
    episodeCount: null,
    posterUrl: item.coverImageUrl,
    backdropUrl: item.thumbnailImageUrl,
    seasons: const <TvSeason>[],
    media: [
      if (item.video?.nrDiscs != null)
        TvReleaseMedia(
          id: '${item.id}:disc:1',
          releaseId: item.id,
          title: 'Disc 1',
          formatLabel: item.physicalFormatLabel,
          discNumber: 1,
          sequenceNumber: 1,
          features: const <String>[],
          episodes: const <TvEpisode>[],
          metadata: const <String, dynamic>{},
        ),
    ],
    contributions: item.creators ?? const <Map<String, dynamic>>[],
    identifiers: const <Map<String, dynamic>>[],
    characterAppearances: item.characterDetails ?? const <Map<String, dynamic>>[],
  );
}

TvSeries _seriesFromWorkspaceEntry(LibraryWorkspaceEntry entry) {
  return TvSeries(
    id: entry.titleItemId ?? entry.id,
    title: entry.title,
    originalTitle: entry.originalTitle,
    overview: entry.synopsis,
    firstAirDate: entry.releaseDate,
    lastAirDate: entry.releaseDate,
    status: null,
    type: entry.mediaType,
    network: entry.publisher,
    originalLanguage: entry.language,
    country: entry.country,
    runtimeMinutes: entry.video?.runtimeMinutes,
    seasonCount: entry.video?.nrDiscs,
    episodeCount: null,
    posterUrl: entry.coverImageUrl,
    backdropUrl: entry.thumbnailImageUrl,
    seasons: const <TvSeason>[],
    media: const <TvReleaseMedia>[],
    contributions: entry.creators ?? const <Map<String, dynamic>>[],
    identifiers: const <Map<String, dynamic>>[],
    characterAppearances: const <Map<String, dynamic>>[],
  );
}

TvRelease _releaseFromRequest(LibraryReleaseEntryRequest request) {
  final discs = [
    for (final disc in request.edition.discs)
      TvReleaseMedia(
        id: '${request.edition.id}:disc:${disc.discNumber}',
        releaseId: request.edition.id,
        title: disc.discName ?? 'Disc ${disc.discNumber}',
        formatLabel: disc.discFormat,
        discNumber: disc.discNumber,
        sequenceNumber: disc.discNumber,
        features: const <String>[],
        episodes: const <TvEpisode>[],
        metadata: disc.toJson(),
      ),
  ];
  return TvRelease(
    id: request.edition.id,
    seriesId: request.titleEntry.titleItemId ?? request.titleEntry.id,
    title: request.edition.title,
    releaseDate: request.edition.releaseDate,
    country: request.edition.region ?? request.titleEntry.country,
    language: request.edition.language ?? request.titleEntry.language,
    media: discs,
  );
}
