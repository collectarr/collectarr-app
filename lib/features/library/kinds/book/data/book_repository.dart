import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/data/remote/book_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:drift/drift.dart';

final class BookRepository implements ReadRepository<BookMediaId, BookMedia> {
  BookRepository(this._db, {BookRemoteSource? remote}) : _remote = remote;

  final LocalDatabase _db;
  final BookRemoteSource? _remote;

  @override
  Future<BookMedia?> findById(BookMediaId id) => getMedia(id);

  Future<BookMedia?> getMedia(BookMediaId id) async {
    final row = await (_db.select(_db.bookMediaRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row != null) {
      return BookLocalMapper.fromMediaRow(
        row,
        editions: await releasesFor(id),
      );
    }

    final remote = _remote;
    if (remote == null) return null;
    final media = await remote.fetchMedia(id);
    await updateMedia(media);
    return media;
  }

  Future<List<BookMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.bookMediaRows);
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
    final result = <BookMedia>[];
    for (final row in rows) {
      result.add(
        BookLocalMapper.fromMediaRow(
          row,
          editions: await releasesFor(BookMediaId(row.id)),
        ),
      );
    }
    return result;
  }

  Future<List<BookRelease>> releasesFor(BookMediaId mediaId) async {
    final query = _db.select(_db.bookReleaseRows)
      ..where((table) => table.mediaId.equals(mediaId.value))
      ..orderBy([
        (table) => OrderingTerm.asc(table.releaseDate),
        (table) => OrderingTerm.asc(table.title),
        (table) => OrderingTerm.asc(table.id),
      ]);
    final rows = await query.get();
    return rows.map(BookLocalMapper.fromReleaseRow).toList(growable: false);
  }

  Future<BookRelease?> getRelease(
    BookMediaId mediaId,
    BookReleaseId releaseId,
  ) async {
    final row = await (_db.select(_db.bookReleaseRows)
          ..where(
            (table) =>
                table.mediaId.equals(mediaId.value) &
                table.id.equals(releaseId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : BookLocalMapper.fromReleaseRow(row);
  }

  Future<void> updateMedia(BookMedia media) async {
    if (media.id.value.isEmpty) {
      throw StateError('Cannot update BookMedia without an id');
    }

    await _db.transaction(() async {
      await _db
          .into(_db.bookMediaRows)
          .insertOnConflictUpdate(BookLocalMapper.toMediaRow(media));
      for (final edition in media.editions) {
        await _db.into(_db.bookReleaseRows).insertOnConflictUpdate(
              BookLocalMapper.toReleaseRow(media.id, edition),
            );
      }
    });
  }

  Future<void> updateRelease(BookMediaId mediaId, BookRelease release) {
    return _db.into(_db.bookReleaseRows).insertOnConflictUpdate(
          BookLocalMapper.toReleaseRow(mediaId, release),
        );
  }

  Future<BookOwnedDetails?> getOwnedDetails(String ownedItemId) async {
    final row = await (_db.select(_db.bookOwnedDetailsRows)
          ..where((table) => table.ownedItemId.equals(ownedItemId)))
        .getSingleOrNull();
    return row == null ? null : BookLocalMapper.fromOwnedDetailsRow(row);
  }

  Future<void> updateOwnedDetails(
    String ownedItemId,
    BookOwnedDetails details,
  ) {
    return _db.into(_db.bookOwnedDetailsRows).insertOnConflictUpdate(
          BookLocalMapper.toOwnedDetailsRow(ownedItemId, details),
        );
  }
}
