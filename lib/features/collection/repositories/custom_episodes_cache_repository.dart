import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:drift/drift.dart';

class CustomEpisodesCacheRepository {
  CustomEpisodesCacheRepository(this._db);

  final LocalDatabase _db;

  /// All active (non-deleted) custom episodes for a specific item.
  Future<List<CustomEpisode>> listByItemId(String itemId) async {
    final query = _db.select(_db.customEpisodesCache)
      ..where((t) => t.itemId.equals(itemId) & t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.asc(t.seasonNumber),
        (t) => OrderingTerm.asc(t.episodeNumber),
      ]);
    return (await query.get()).map(_fromRow).toList();
  }

  /// All active custom episodes grouped by season number.
  Future<Map<int, List<CustomEpisode>>> listByItemIdGrouped(
    String itemId,
  ) async {
    final episodes = await listByItemId(itemId);
    final grouped = <int, List<CustomEpisode>>{};
    for (final ep in episodes) {
      grouped.putIfAbsent(ep.seasonNumber, () => <CustomEpisode>[]).add(ep);
    }
    return grouped;
  }

  /// All active custom episodes.
  Future<List<CustomEpisode>> listActive() async {
    final query = _db.select(_db.customEpisodesCache)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.asc(t.itemId),
        (t) => OrderingTerm.asc(t.seasonNumber),
        (t) => OrderingTerm.asc(t.episodeNumber),
      ]);
    return (await query.get()).map(_fromRow).toList();
  }

  Future<CustomEpisode?> findById(String id) async {
    final query = _db.select(_db.customEpisodesCache)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<void> upsert(CustomEpisode episode) {
    return _db.into(_db.customEpisodesCache).insertOnConflictUpdate(
          CustomEpisodesCacheCompanion.insert(
            id: episode.id,
            itemId: episode.itemId,
            seasonNumber: episode.seasonNumber,
            episodeNumber: episode.episodeNumber,
            title: episode.title,
            overview: Value(episode.overview),
            airDate: Value(episode.airDate),
            runtimeMinutes: Value(episode.runtimeMinutes),
            updatedAt: episode.updatedAt,
            deletedAt: Value(episode.deletedAt),
          ),
        );
  }

  Future<void> upsertAll(List<CustomEpisode> episodes) async {
    await _db.batch((batch) {
      for (final episode in episodes) {
        batch.insert(
          _db.customEpisodesCache,
          CustomEpisodesCacheCompanion.insert(
            id: episode.id,
            itemId: episode.itemId,
            seasonNumber: episode.seasonNumber,
            episodeNumber: episode.episodeNumber,
            title: episode.title,
            overview: Value(episode.overview),
            airDate: Value(episode.airDate),
            runtimeMinutes: Value(episode.runtimeMinutes),
            updatedAt: episode.updatedAt,
            deletedAt: Value(episode.deletedAt),
          ),
          onConflict: DoUpdate((_) => CustomEpisodesCacheCompanion(
                itemId: Value(episode.itemId),
                seasonNumber: Value(episode.seasonNumber),
                episodeNumber: Value(episode.episodeNumber),
                title: Value(episode.title),
                overview: Value(episode.overview),
                airDate: Value(episode.airDate),
                runtimeMinutes: Value(episode.runtimeMinutes),
                updatedAt: Value(episode.updatedAt),
                deletedAt: Value(episode.deletedAt),
              )),
        );
      }
    });
  }

  Future<void> markDeleted(CustomEpisode episode, DateTime now) {
    return upsert(episode.copyWith(deletedAt: now, updatedAt: now));
  }

  CustomEpisode _fromRow(CustomEpisodesCacheData row) {
    return CustomEpisode(
      id: row.id,
      seriesRef: CatalogEntityRef(
        kind: 'tv',
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      title: row.title,
      overview: row.overview,
      airDate: row.airDate,
      runtimeMinutes: row.runtimeMinutes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
