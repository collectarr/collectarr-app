import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/data/remote/game_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:drift/drift.dart';

final class GameRepository implements ReadRepository<GameMediaId, GameMedia> {
  GameRepository(this._db, {GameRemoteSource? remote}) : _remote = remote;

  final LocalDatabase _db;
  final GameRemoteSource? _remote;

  @override
  Future<GameMedia?> findById(GameMediaId id) => getMedia(id);

  Future<GameMedia?> getMedia(GameMediaId id) async {
    final row = await (_db.select(_db.gameMediaRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row != null) {
      return GameLocalMapper.fromMediaRow(
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

  Future<List<GameMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.gameMediaRows);
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
    final result = <GameMedia>[];
    for (final row in rows) {
      result.add(
        GameLocalMapper.fromMediaRow(
          row,
          releases: await releasesFor(GameMediaId(row.id)),
        ),
      );
    }
    return result;
  }

  Future<List<GameRelease>> releasesFor(GameMediaId mediaId) async {
    final query = _db.select(_db.gameReleaseRows)
      ..where((table) => table.mediaId.equals(mediaId.value))
      ..orderBy([
        (table) => OrderingTerm.asc(table.releaseDate),
        (table) => OrderingTerm.asc(table.title),
        (table) => OrderingTerm.asc(table.id),
      ]);
    final rows = await query.get();
    return rows.map(GameLocalMapper.fromReleaseRow).toList(growable: false);
  }

  Future<GameRelease?> getRelease(
    GameMediaId mediaId,
    GameReleaseId releaseId,
  ) async {
    final row = await (_db.select(_db.gameReleaseRows)
          ..where(
            (table) =>
                table.mediaId.equals(mediaId.value) &
                table.id.equals(releaseId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : GameLocalMapper.fromReleaseRow(row);
  }

  Future<void> updateMedia(GameMedia media) async {
    if (media.id.value.isEmpty) {
      throw StateError('Cannot update GameMedia without an id');
    }

    await _db.transaction(() async {
      await _db
          .into(_db.gameMediaRows)
          .insertOnConflictUpdate(GameLocalMapper.toMediaRow(media));
      for (final release in media.releases) {
        await _db.into(_db.gameReleaseRows).insertOnConflictUpdate(
              GameLocalMapper.toReleaseRow(media.id, release),
            );
      }
    });
  }

  Future<void> updateRelease(GameMediaId mediaId, GameRelease release) {
    return _db.into(_db.gameReleaseRows).insertOnConflictUpdate(
          GameLocalMapper.toReleaseRow(mediaId, release),
        );
  }

  Future<GameOwnedDetails?> getOwnedDetails(String ownedItemId) async {
    final row = await (_db.select(_db.gameOwnedDetailsRows)
          ..where((table) => table.ownedItemId.equals(ownedItemId)))
        .getSingleOrNull();
    return row == null ? null : GameLocalMapper.fromOwnedDetailsRow(row);
  }

  Future<void> updateOwnedDetails(
    String ownedItemId,
    GameOwnedDetails details,
  ) {
    return _db.into(_db.gameOwnedDetailsRows).insertOnConflictUpdate(
          GameLocalMapper.toOwnedDetailsRow(ownedItemId, details),
        );
  }
}
