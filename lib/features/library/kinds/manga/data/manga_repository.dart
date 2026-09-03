import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/remote/manga_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:drift/drift.dart';

final class MangaRepository {
  MangaRepository(this._db, {MangaRemoteSource? remote}) : _remote = remote;

  final LocalDatabase _db;
  final MangaRemoteSource? _remote;

  Future<MangaMedia?> getMedia(String id) async {
    final row = await (_db.select(_db.mangaMediaRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    if (row != null) return MangaLocalMapper.fromMediaRow(row);

    final remote = _remote;
    if (remote == null) return null;
    final media = await remote.fetchMedia(id);
    await updateMedia(media);
    return media;
  }

  Future<List<MangaMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.mangaMediaRows);
    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      select.where(
        (table) =>
            table.title.like(pattern) | table.sortTitle.like(pattern),
      );
    }
    select.orderBy([
      (table) => OrderingTerm.asc(table.sortTitle),
      (table) => OrderingTerm.asc(table.title),
      (table) => OrderingTerm.asc(table.id),
    ]);

    final rows = await select.get();
    return rows.map(MangaLocalMapper.fromMediaRow).toList(growable: false);
  }

  Future<void> updateMedia(MangaMedia media) {
    return _db
        .into(_db.mangaMediaRows)
        .insertOnConflictUpdate(MangaLocalMapper.toMediaRow(media));
  }

  Future<MangaOwnedDetails?> getOwnedDetails(String ownedItemId) async {
    final row = await (_db.select(_db.mangaOwnedDetailsRows)
          ..where((table) => table.ownedItemId.equals(ownedItemId)))
        .getSingleOrNull();
    return row == null ? null : MangaLocalMapper.fromOwnedDetailsRow(row);
  }

  Future<void> updateOwnedDetails(
    String ownedItemId,
    MangaOwnedDetails details,
  ) {
    return _db
        .into(_db.mangaOwnedDetailsRows)
        .insertOnConflictUpdate(
          MangaLocalMapper.toOwnedDetailsRow(ownedItemId, details),
        );
  }
}
