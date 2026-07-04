import 'package:collectarr_app/core/models/catalog_item.dart';
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
