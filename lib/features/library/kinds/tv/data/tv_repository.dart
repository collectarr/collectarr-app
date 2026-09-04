import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:drift/drift.dart';

final class TvRepository {
  TvRepository(this._db, {TvRemoteSource? remote}) : _remote = remote;

  final LocalDatabase _db;
  final TvRemoteSource? _remote;

  Future<TvSeries?> getSeries(TvSeriesId id) async {
    final row = await (_db.select(_db.tvSeriesRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row != null) return _hydrateSeries(row);

    final remote = _remote;
    if (remote == null) return null;
    final series = await remote.fetchSeries(id);
    await updateSeries(series);
    return series;
  }

  Future<List<TvSeries>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.tvSeriesRows);
    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      select.where(
        (table) => table.title.like(pattern) | table.sortTitle.like(pattern),
      );
    }
    select.orderBy([
      (table) => OrderingTerm.asc(table.sortTitle),
      (table) => OrderingTerm.asc(table.title),
      (table) => OrderingTerm.asc(table.id),
    ]);
    final rows = await select.get();
    return [for (final row in rows) await _hydrateSeries(row)];
  }

  Future<List<TvSeason>> seasonsFor(TvSeriesId seriesId) async {
    final rows = await (_db.select(_db.tvSeasonRows)
          ..where((table) => table.seriesId.equals(seriesId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.seasonNumber),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return [
      for (final row in rows)
        TvLocalMapper.fromSeasonRow(
          row,
          episodes: await episodesFor(TvSeasonId(row.id)),
        ),
    ];
  }

  Future<TvSeason?> getSeason(
    TvSeriesId seriesId,
    TvSeasonId seasonId,
  ) async {
    final row = await (_db.select(_db.tvSeasonRows)
          ..where(
            (table) =>
                table.seriesId.equals(seriesId.value) &
                table.id.equals(seasonId.value),
          ))
        .getSingleOrNull();
    return row == null
        ? null
        : TvLocalMapper.fromSeasonRow(
            row,
            episodes: await episodesFor(seasonId),
          );
  }

  Future<List<TvEpisode>> episodesFor(TvSeasonId seasonId) async {
    final rows = await (_db.select(_db.tvEpisodeRows)
          ..where((table) => table.seasonId.equals(seasonId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.episodeNumber),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows.map(TvLocalMapper.fromEpisodeRow).toList(growable: false);
  }

  Future<List<TvRelease>> releasesFor(TvSeriesId seriesId) async {
    final rows = await (_db.select(_db.tvReleaseRows)
          ..where((table) => table.seriesId.equals(seriesId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.releaseDate),
            (table) => OrderingTerm.asc(table.title),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return [for (final row in rows) await _hydrateRelease(row)];
  }

  Future<TvRelease?> getRelease(
    TvSeriesId seriesId,
    TvReleaseId releaseId,
  ) async {
    final row = await (_db.select(_db.tvReleaseRows)
          ..where(
            (table) =>
                table.seriesId.equals(seriesId.value) &
                table.id.equals(releaseId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : _hydrateRelease(row);
  }

  Future<void> updateSeries(TvSeries series) async {
    if (series.id.trim().isEmpty) {
      throw StateError('Cannot update TvSeries without an id');
    }

    await _db.transaction(() async {
      await _deleteSeriesGraph(series.typedId);
      await _db
          .into(_db.tvSeriesRows)
          .insertOnConflictUpdate(TvLocalMapper.toSeriesRow(series));
      for (final season in series.seasons) {
        await _db.into(_db.tvSeasonRows).insertOnConflictUpdate(
              TvLocalMapper.toSeasonRow(series.typedId, season),
            );
        for (final episode in season.episodes) {
          await _db.into(_db.tvEpisodeRows).insertOnConflictUpdate(
                TvLocalMapper.toEpisodeRow(episode),
              );
        }
      }
      for (final release in series.releases) {
        await _db.into(_db.tvReleaseRows).insertOnConflictUpdate(
              TvLocalMapper.toReleaseRow(series.typedId, release),
            );
        for (final media in release.media) {
          await _db.into(_db.tvReleaseMediaRows).insertOnConflictUpdate(
                TvLocalMapper.toReleaseMediaRow(release.typedId, media),
              );
        }
        for (final mapping in release.episodeMappings) {
          await _db.into(_db.tvReleaseEpisodeMapRows).insertOnConflictUpdate(
                TvLocalMapper.toReleaseEpisodeMapRow(
                  release.typedId,
                  mapping,
                ),
              );
        }
      }
    });
  }

  Future<void> updateSeason(TvSeriesId seriesId, TvSeason season) async {
    await _db.transaction(() async {
      await (_db.delete(_db.tvEpisodeRows)
            ..where((table) => table.seasonId.equals(season.id)))
          .go();
      await _db.into(_db.tvSeasonRows).insertOnConflictUpdate(
            TvLocalMapper.toSeasonRow(seriesId, season),
          );
      for (final episode in season.episodes) {
        await _db.into(_db.tvEpisodeRows).insertOnConflictUpdate(
              TvLocalMapper.toEpisodeRow(episode),
            );
      }
    });
  }

  Future<void> updateRelease(TvSeriesId seriesId, TvRelease release) async {
    await _db.transaction(() async {
      await (_db.delete(_db.tvReleaseMediaRows)
            ..where((table) => table.releaseId.equals(release.id)))
          .go();
      await (_db.delete(_db.tvReleaseEpisodeMapRows)
            ..where((table) => table.releaseId.equals(release.id)))
          .go();
      await _db.into(_db.tvReleaseRows).insertOnConflictUpdate(
            TvLocalMapper.toReleaseRow(seriesId, release),
          );
      for (final media in release.media) {
        await _db.into(_db.tvReleaseMediaRows).insertOnConflictUpdate(
              TvLocalMapper.toReleaseMediaRow(release.typedId, media),
            );
      }
      for (final mapping in release.episodeMappings) {
        await _db.into(_db.tvReleaseEpisodeMapRows).insertOnConflictUpdate(
              TvLocalMapper.toReleaseEpisodeMapRow(release.typedId, mapping),
            );
      }
    });
  }

  Future<TvOwnedDetails?> getOwnedDetails(String ownedItemId) async {
    final row = await (_db.select(_db.tvOwnedDetailsRows)
          ..where((table) => table.ownedItemId.equals(ownedItemId)))
        .getSingleOrNull();
    return row == null ? null : TvLocalMapper.fromOwnedDetailsRow(row);
  }

  Future<void> updateOwnedDetails(
    String ownedItemId,
    TvOwnedDetails details,
  ) {
    return _db.into(_db.tvOwnedDetailsRows).insertOnConflictUpdate(
          TvLocalMapper.toOwnedDetailsRow(ownedItemId, details),
        );
  }

  Future<TvSeries> _hydrateSeries(TvSeriesRow row) async {
    final seasons = await seasonsFor(TvSeriesId(row.id));
    final releases = await releasesFor(TvSeriesId(row.id));
    final media = <TvReleaseMedia>[];
    final mappings = <TvReleaseEpisodeMap>[];
    for (final release in releases) {
      media.addAll(release.media);
      mappings.addAll(release.episodeMappings);
    }
    return TvLocalMapper.fromSeriesRow(
      row,
      seasons: seasons,
      releases: releases,
      media: media,
      releaseEpisodeMaps: mappings,
    );
  }

  Future<TvRelease> _hydrateRelease(TvReleaseRow row) async {
    final mediaRows = await (_db.select(_db.tvReleaseMediaRows)
          ..where((table) => table.releaseId.equals(row.id))
          ..orderBy([
            (table) => OrderingTerm.asc(table.mediaNumber),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    final mapRows = await (_db.select(_db.tvReleaseEpisodeMapRows)
          ..where((table) => table.releaseId.equals(row.id))
          ..orderBy([
            (table) => OrderingTerm.asc(table.discNumber),
            (table) => OrderingTerm.asc(table.sequenceNumber),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return TvLocalMapper.fromReleaseRow(
      row,
      media: mediaRows.map(TvLocalMapper.fromReleaseMediaRow).toList(),
      episodeMappings:
          mapRows.map(TvLocalMapper.fromReleaseEpisodeMapRow).toList(),
    );
  }

  Future<void> _deleteSeriesGraph(TvSeriesId seriesId) async {
    final releaseRows = await (_db.select(_db.tvReleaseRows)
          ..where((table) => table.seriesId.equals(seriesId.value)))
        .get();
    for (final release in releaseRows) {
      await (_db.delete(_db.tvReleaseMediaRows)
            ..where((table) => table.releaseId.equals(release.id)))
          .go();
      await (_db.delete(_db.tvReleaseEpisodeMapRows)
            ..where((table) => table.releaseId.equals(release.id)))
          .go();
    }
    await (_db.delete(_db.tvReleaseRows)
          ..where((table) => table.seriesId.equals(seriesId.value)))
        .go();
    await (_db.delete(_db.tvEpisodeRows)
          ..where((table) => table.seriesId.equals(seriesId.value)))
        .go();
    await (_db.delete(_db.tvSeasonRows)
          ..where((table) => table.seriesId.equals(seriesId.value)))
        .go();
  }
}
