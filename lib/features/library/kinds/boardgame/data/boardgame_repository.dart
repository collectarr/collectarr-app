import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/remote/boardgame_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:drift/drift.dart';

final class BoardGameRepository
    implements ReadRepository<BoardGameMediaId, BoardGameMedia> {
  BoardGameRepository(this._db, {BoardGameRemoteSource? remote})
      : _remote = remote;

  final LocalDatabase _db;
  final BoardGameRemoteSource? _remote;

  @override
  Future<BoardGameMedia?> findById(BoardGameMediaId id) => getMedia(id);

  Future<BoardGameMedia?> getMedia(BoardGameMediaId id) async {
    final row = await (_db.select(_db.boardGameMediaRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row != null) {
      return BoardGameLocalMapper.fromMediaRow(
        row,
        editions: await editionsFor(id),
      );
    }

    final remote = _remote;
    if (remote == null) return null;
    final media = await remote.fetchMedia(id);
    await updateMedia(media);
    return media;
  }

  Future<List<BoardGameMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.boardGameMediaRows);
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
    final result = <BoardGameMedia>[];
    for (final row in rows) {
      result.add(
        BoardGameLocalMapper.fromMediaRow(
          row,
          editions: await editionsFor(BoardGameMediaId(row.id)),
        ),
      );
    }
    return result;
  }

  Future<List<BoardGameEdition>> editionsFor(BoardGameMediaId mediaId) async {
    final query = _db.select(_db.boardGameEditionRows)
      ..where((table) => table.mediaId.equals(mediaId.value))
      ..orderBy([
        (table) => OrderingTerm.asc(table.releaseDate),
        (table) => OrderingTerm.asc(table.title),
        (table) => OrderingTerm.asc(table.id),
      ]);
    final rows = await query.get();
    return rows
        .map(BoardGameLocalMapper.fromEditionRow)
        .toList(growable: false);
  }

  Future<BoardGameEdition?> getEdition(
    BoardGameMediaId mediaId,
    BoardGameEditionId editionId,
  ) async {
    final row = await (_db.select(_db.boardGameEditionRows)
          ..where(
            (table) =>
                table.mediaId.equals(mediaId.value) &
                table.id.equals(editionId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : BoardGameLocalMapper.fromEditionRow(row);
  }

  Future<void> updateMedia(BoardGameMedia media) async {
    if (media.id.value.isEmpty) {
      throw StateError('Cannot update BoardGameMedia without an id');
    }

    await _db.transaction(() async {
      await _db
          .into(_db.boardGameMediaRows)
          .insertOnConflictUpdate(BoardGameLocalMapper.toMediaRow(media));
      for (final edition in media.editions) {
        await _db.into(_db.boardGameEditionRows).insertOnConflictUpdate(
              BoardGameLocalMapper.toEditionRow(media.id, edition),
            );
      }
    });
  }

  Future<void> updateEdition(
    BoardGameMediaId mediaId,
    BoardGameEdition edition,
  ) {
    return _db.into(_db.boardGameEditionRows).insertOnConflictUpdate(
          BoardGameLocalMapper.toEditionRow(mediaId, edition),
        );
  }

  Future<BoardgameOwnedDetails?> getOwnedDetails(String ownedItemId) async {
    final row = await (_db.select(_db.boardGameOwnedDetailsRows)
          ..where((table) => table.ownedItemId.equals(ownedItemId)))
        .getSingleOrNull();
    return row == null ? null : BoardGameLocalMapper.fromOwnedDetailsRow(row);
  }

  Future<void> updateOwnedDetails(
    String ownedItemId,
    BoardgameOwnedDetails details,
  ) {
    return _db.into(_db.boardGameOwnedDetailsRows).insertOnConflictUpdate(
          BoardGameLocalMapper.toOwnedDetailsRow(ownedItemId, details),
        );
  }
}
