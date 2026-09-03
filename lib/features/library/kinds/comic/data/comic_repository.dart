import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:drift/drift.dart';

final class ComicRepository {
  ComicRepository(this._db, {ComicRemoteSource? remote}) : _remote = remote;

  final LocalDatabase _db;
  final ComicRemoteSource? _remote;

  Future<ComicMedia?> getMedia(ComicMediaId id) async {
    final row = await (_db.select(_db.comicMediaRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row != null) {
      return ComicLocalMapper.fromMediaRow(
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

  Future<List<ComicMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.comicMediaRows);
    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      select.where(
        (table) =>
            table.title.like(pattern) |
            table.sortTitle.like(pattern) |
            table.seriesTitle.like(pattern) |
            table.issueNumber.like(pattern),
      );
    }
    select.orderBy([
      (table) => OrderingTerm.asc(table.sortTitle),
      (table) => OrderingTerm.asc(table.title),
      (table) => OrderingTerm.asc(table.id),
    ]);

    final rows = await select.get();
    final result = <ComicMedia>[];
    for (final row in rows) {
      result.add(
        ComicLocalMapper.fromMediaRow(
          row,
          releases: await releasesFor(ComicMediaId(row.id)),
        ),
      );
    }
    return result;
  }

  Future<List<ComicRelease>> releasesFor(ComicMediaId mediaId) async {
    final query = _db.select(_db.comicReleaseRows)
      ..where((table) => table.mediaId.equals(mediaId.value))
      ..orderBy([
        (table) => OrderingTerm.asc(table.releaseDate),
        (table) => OrderingTerm.asc(table.title),
        (table) => OrderingTerm.asc(table.id),
      ]);
    final rows = await query.get();
    return rows.map(ComicLocalMapper.fromReleaseRow).toList(growable: false);
  }

  Future<ComicRelease?> getRelease(
    ComicMediaId mediaId,
    ComicReleaseId releaseId,
  ) async {
    final row = await (_db.select(_db.comicReleaseRows)
          ..where(
            (table) =>
                table.mediaId.equals(mediaId.value) &
                table.id.equals(releaseId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : ComicLocalMapper.fromReleaseRow(row);
  }

  Future<void> updateMedia(ComicMedia media) async {
    final mediaId = media.id;
    if (mediaId == null || mediaId.value.isEmpty) {
      throw StateError('Cannot update ComicMedia without an id');
    }

    await _db.transaction(() async {
      await _db
          .into(_db.comicMediaRows)
          .insertOnConflictUpdate(ComicLocalMapper.toMediaRow(media));
      for (final release in media.releases) {
        await _db.into(_db.comicReleaseRows).insertOnConflictUpdate(
              ComicLocalMapper.toReleaseRow(mediaId, release),
            );
      }
    });
  }

  Future<void> updateRelease(
    ComicMediaId mediaId,
    ComicRelease release,
  ) {
    return _db.into(_db.comicReleaseRows).insertOnConflictUpdate(
          ComicLocalMapper.toReleaseRow(mediaId, release),
        );
  }
}
