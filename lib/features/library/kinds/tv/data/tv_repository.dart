import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

/// Reads TV catalog data from the shared Catalog Item cache.
///
/// Seasons, episodes, and included physical contents remain contained in each
/// cached Catalog Item payload. App-owned viewing and copy state stays in its
/// dedicated TV tables.
final class TvRepository implements ReadRepository<TvSeriesId, TvSeries> {
  TvRepository(this._db);

  final LocalDatabase _db;
  CatalogItemCacheRepository get _cache => CatalogItemCacheRepository(_db);

  @override
  Future<TvSeries?> findById(TvSeriesId id) => getSeries(id);

  Future<TvSeries?> getSeries(TvSeriesId id) async {
    final item = await _cache.find(
      CatalogItemRef(kind: CatalogMediaKind.tv, id: id.value),
    );
    return item == null ? null : _decode(item);
  }

  Future<List<TvSeries>> search([String query = '']) async {
    final normalizedQuery = query.trim().toLowerCase();
    final items = await _cache.findAll(kind: CatalogMediaKind.tv);
    final series = [for (final item in items) _decode(item)];
    if (normalizedQuery.isNotEmpty) {
      series.removeWhere((item) =>
          !item.title.toLowerCase().contains(normalizedQuery) &&
          !(item.sortTitle?.toLowerCase().contains(normalizedQuery) ?? false));
    }
    series.sort((left, right) {
      final bySortTitle = (left.sortTitle ?? left.title)
          .toLowerCase()
          .compareTo((right.sortTitle ?? right.title).toLowerCase());
      if (bySortTitle != 0) return bySortTitle;
      final byTitle =
          left.title.toLowerCase().compareTo(right.title.toLowerCase());
      return byTitle != 0 ? byTitle : left.id.compareTo(right.id);
    });
    return series;
  }

  Future<List<TvSeason>> seasonsFor(TvSeriesId seriesId) async {
    final series = await getSeries(seriesId);
    if (series == null) return const [];
    final seasons = [...series.seasons]..sort((left, right) {
        final byNumber =
            (left.seasonNumber ?? 0).compareTo(right.seasonNumber ?? 0);
        return byNumber != 0 ? byNumber : left.id.compareTo(right.id);
      });
    return seasons;
  }

  Future<TvSeason?> getSeason(
    TvSeriesId seriesId,
    TvSeasonId seasonId,
  ) async {
    for (final season in await seasonsFor(seriesId)) {
      if (season.id == seasonId.value) return season;
    }
    return null;
  }

  Future<List<TvEpisode>> episodesFor(TvSeasonId seasonId) async {
    for (final series in await search()) {
      for (final season in series.seasons) {
        if (season.id != seasonId.value) continue;
        final episodes = [...season.episodes]..sort((left, right) {
            final byNumber =
                (left.episodeNumber ?? 0).compareTo(right.episodeNumber ?? 0);
            return byNumber != 0 ? byNumber : left.id.compareTo(right.id);
          });
        return episodes;
      }
    }
    return const [];
  }

  Future<List<TvRelease>> releasesFor(TvSeriesId seriesId) async {
    final series = await getSeries(seriesId);
    if (series == null) return const [];
    final releases = [...series.releases]..sort((left, right) {
        final byDate = (left.releaseDate ?? DateTime(1))
            .compareTo(right.releaseDate ?? DateTime(1));
        if (byDate != 0) return byDate;
        final byTitle = left.title.compareTo(right.title);
        return byTitle != 0 ? byTitle : left.id.compareTo(right.id);
      });
    return releases;
  }

  Future<TvRelease?> getRelease(
    TvSeriesId seriesId,
    TvReleaseId releaseId,
  ) async {
    for (final release in await releasesFor(seriesId)) {
      if (release.id == releaseId.value) return release;
    }
    return null;
  }

  Future<void> updateSeries(TvSeries series) async {
    if (series.id.trim().isEmpty) {
      throw StateError('Cannot update TvSeries without an id');
    }
    await _cache.upsert(_toCatalogItem(series));
  }

  Future<void> updateSeason(TvSeriesId seriesId, TvSeason season) async {
    final series = await getSeries(seriesId);
    if (series == null) {
      throw StateError(
          'Cannot update season for missing TV Catalog Item ${seriesId.value}');
    }
    final seasons = [...series.seasons];
    final index = seasons.indexWhere((current) => current.id == season.id);
    if (index < 0) {
      seasons.add(season);
    } else {
      seasons[index] = season;
    }
    await updateSeries(_replaceChildren(series, seasons: seasons));
  }

  Future<void> updateRelease(TvSeriesId seriesId, TvRelease release) async {
    final series = await getSeries(seriesId);
    if (series == null) {
      throw StateError(
          'Cannot update release for missing TV Catalog Item ${seriesId.value}');
    }
    final releases = [...series.releases];
    final index = releases.indexWhere((current) => current.id == release.id);
    if (index < 0) {
      releases.add(release);
    } else {
      releases[index] = release;
    }
    await updateSeries(_replaceChildren(series, releases: releases));
  }

  TvSeries _decode(CatalogItemDto item) =>
      TvSeries.fromJson(catalogTransportPayloadFor(item));

  CatalogItemDto _toCatalogItem(TvSeries series) => CatalogItemDto.raw(
        id: series.id,
        mediaKind: CatalogMediaKind.tv,
        kindData: series.toJson(),
      );

  TvSeries _replaceChildren(
    TvSeries series, {
    List<TvSeason>? seasons,
    List<TvRelease>? releases,
  }) =>
      TvSeries.fromJson({
        ...series.toJson(),
        if (seasons != null)
          'seasons': seasons.map((item) => item.toJson()).toList(),
        if (releases != null)
          'releases': releases.map((item) => item.toJson()).toList(),
        if (releases != null)
          'media': [
            for (final release in releases)
              ...release.media.map((item) => item.toJson())
          ],
        if (releases != null)
          'episode_mappings': [
            for (final release in releases)
              ...release.episodeMappings.map((item) => item.toJson()),
          ],
      });
}
