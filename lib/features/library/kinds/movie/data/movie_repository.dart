import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/remote/movie_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:drift/drift.dart';

final class MovieRepository {
  MovieRepository(this._db, {MovieRemoteSource? remote}) : _remote = remote;

  final LocalDatabase _db;
  final MovieRemoteSource? _remote;

  Future<MovieMedia?> getMedia(MovieMediaId id) async {
    final row = await (_db.select(_db.movieMediaRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row != null) {
      return MovieLocalMapper.fromMediaRow(
        row,
        releases: await releasesFor(id),
      );
    }

    final remote = _remote;
    if (remote == null) return null;
    final media = await remote.fetchMedia(id);
    await updateMedia(media);
    return media;
  }

  Future<List<MovieMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.movieMediaRows);
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
    final result = <MovieMedia>[];
    for (final row in rows) {
      result.add(
        MovieLocalMapper.fromMediaRow(
          row,
          releases: await releasesFor(MovieMediaId(row.id)),
        ),
      );
    }
    return result;
  }

  Future<List<MovieRelease>> releasesFor(MovieMediaId mediaId) async {
    final query = _db.select(_db.movieReleaseRows)
      ..where((table) => table.mediaId.equals(mediaId.value))
      ..orderBy([
        (table) => OrderingTerm.asc(table.releaseDate),
        (table) => OrderingTerm.asc(table.title),
        (table) => OrderingTerm.asc(table.id),
      ]);
    final rows = await query.get();
    return rows.map(MovieLocalMapper.fromReleaseRow).toList(growable: false);
  }

  Future<MovieRelease?> getRelease(
    MovieMediaId mediaId,
    MovieReleaseId releaseId,
  ) async {
    final row = await (_db.select(_db.movieReleaseRows)
          ..where(
            (table) =>
                table.mediaId.equals(mediaId.value) &
                table.id.equals(releaseId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : MovieLocalMapper.fromReleaseRow(row);
  }

  Future<void> updateMedia(MovieMedia media) async {
    if (media.id.value.isEmpty) {
      throw StateError('Cannot update MovieMedia without an id');
    }

    await _db.transaction(() async {
      await _db
          .into(_db.movieMediaRows)
          .insertOnConflictUpdate(MovieLocalMapper.toMediaRow(media));
      for (final release in media.releases) {
        await _db.into(_db.movieReleaseRows).insertOnConflictUpdate(
              MovieLocalMapper.toReleaseRow(media.id, release),
            );
      }
    });
  }

  Future<void> updateRelease(MovieMediaId mediaId, MovieRelease release) {
    return _db.into(_db.movieReleaseRows).insertOnConflictUpdate(
          MovieLocalMapper.toReleaseRow(mediaId, release),
        );
  }

  Future<MovieOwnedDetails?> getOwnedDetails(String ownedItemId) async {
    final row = await (_db.select(_db.movieOwnedDetailsRows)
          ..where((table) => table.ownedItemId.equals(ownedItemId)))
        .getSingleOrNull();
    return row == null ? null : MovieLocalMapper.fromOwnedDetailsRow(row);
  }

  Future<void> updateOwnedDetails(
    String ownedItemId,
    MovieOwnedDetails details,
  ) {
    return _db.into(_db.movieOwnedDetailsRows).insertOnConflictUpdate(
          MovieLocalMapper.toOwnedDetailsRow(ownedItemId, details),
        );
  }
}
