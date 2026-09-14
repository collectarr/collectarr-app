import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_play_session.dart';
import 'package:drift/drift.dart';

final class BoardGamePlaySessionRepository {
  BoardGamePlaySessionRepository(this._db);

  final LocalDatabase _db;

  Future<List<BoardGamePlaySession>> listForBoardGame(
    BoardGameMediaId boardGameId,
  ) async {
    if (boardGameId.value.isEmpty) return const <BoardGamePlaySession>[];
    final rows = await (_db.select(_db.boardGamePlaySessionsRows)
          ..where((table) => table.boardGameId.equals(boardGameId.value))
          ..orderBy([
            (table) => OrderingTerm.desc(table.date),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows
        .map(BoardGameLocalMapper.fromPlaySessionRow)
        .toList(growable: false);
  }

  Future<List<BoardGamePlaySession>> listAll() async {
    final rows = await (_db.select(_db.boardGamePlaySessionsRows)
          ..orderBy([
            (table) => OrderingTerm.desc(table.date),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows
        .map(BoardGameLocalMapper.fromPlaySessionRow)
        .toList(growable: false);
  }

  Future<BoardGamePlaySession?> findById(String id) async {
    final row = await (_db.select(_db.boardGamePlaySessionsRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : BoardGameLocalMapper.fromPlaySessionRow(row);
  }

  Future<void> upsert(BoardGamePlaySession session) {
    return _db
        .into(_db.boardGamePlaySessionsRows)
        .insertOnConflictUpdate(BoardGameLocalMapper.toPlaySessionRow(session));
  }

  Future<void> upsertAll(Iterable<BoardGamePlaySession> sessions) async {
    final companions = sessions
        .map(BoardGameLocalMapper.toPlaySessionRow)
        .toList(growable: false);
    if (companions.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.boardGamePlaySessionsRows,
        companions,
      );
    });
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.boardGamePlaySessionsRows)
          ..where((table) => table.id.equals(id)))
        .go();
  }
}
