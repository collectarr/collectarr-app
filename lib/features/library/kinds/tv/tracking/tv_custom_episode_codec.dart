import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
import 'package:drift/drift.dart';

final class TvCustomEpisodeCodec implements CustomEpisodeCodec {
  const TvCustomEpisodeCodec();

  @override
  String get kind => 'tv';

  @override
  Future<List<CustomEpisode>> listActive(
    LocalDatabase db, {
    String? itemId,
  }) async {
    final query = db.select(db.tvCustomEpisodeRows)
      ..where((row) => row.deletedAt.isNull());
    if (itemId != null) {
      query.where((row) => row.seriesId.equals(itemId));
    }
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<CustomEpisode?> findById(LocalDatabase db, String id) async {
    final row = await (db.select(db.tvCustomEpisodeRows)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsert(LocalDatabase db, CustomEpisode episode) async {
    if (episode.seriesRef.kind != kind) {
      throw ArgumentError.value(
        episode.seriesRef.kind,
        'episode.seriesRef.kind',
        'Expected TV custom episode',
      );
    }
    await db.into(db.tvCustomEpisodeRows).insertOnConflictUpdate(
          TvCustomEpisodeRowsCompanion.insert(
            id: episode.id,
            seriesId: episode.itemId,
            seasonNumber: episode.seasonNumber,
            episodeNumber: episode.episodeNumber,
            title: episode.title,
            description: Value(episode.overview),
            airDate: Value(_parseDate(episode.airDate)),
            runtimeMinutes: Value(episode.runtimeMinutes),
            stillImageUrl: Value(episode.stillImageUrl),
            localImagePath: Value(episode.localImagePath),
            thumbnailImageUrl: Value(episode.thumbnailImageUrl),
            updatedAt: episode.updatedAt,
            deletedAt: Value(episode.deletedAt),
          ),
        );
  }

  @override
  int compare(CustomEpisode left, CustomEpisode right) {
    final item = left.itemId.compareTo(right.itemId);
    if (item != 0) return item;
    final season = left.seasonNumber.compareTo(right.seasonNumber);
    if (season != 0) return season;
    return left.episodeNumber.compareTo(right.episodeNumber);
  }

  @override
  int groupKey(CustomEpisode episode) => episode.seasonNumber;

  CustomEpisode _fromRow(TvCustomEpisodeRow row) {
    return CustomEpisode(
      id: row.id,
      seriesRef: CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityType.work,
        id: row.seriesId,
      ),
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      title: row.title,
      overview: row.description,
      airDate: _formatDate(row.airDate),
      runtimeMinutes: row.runtimeMinutes,
      stillImageUrl: row.stillImageUrl,
      localImagePath: row.localImagePath,
      thumbnailImageUrl: row.thumbnailImageUrl,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _formatDate(DateTime? value) => value?.toIso8601String();
