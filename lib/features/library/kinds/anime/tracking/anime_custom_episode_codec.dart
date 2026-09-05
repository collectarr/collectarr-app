import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
import 'package:drift/drift.dart';

final class AnimeCustomEpisodeCodec implements CustomEpisodeCodec {
  const AnimeCustomEpisodeCodec();

  @override
  String get kind => 'anime';

  @override
  Future<List<CustomEpisode>> listActive(
    LocalDatabase db, {
    String? itemId,
  }) async {
    final query = db.select(db.animeCustomEpisodeRows)
      ..where((row) => row.deletedAt.isNull());
    if (itemId != null) {
      query.where((row) => row.seriesId.equals(itemId));
    }
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<CustomEpisode?> findById(LocalDatabase db, String id) async {
    final row = await (db.select(db.animeCustomEpisodeRows)
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
        'Expected Anime custom episode',
      );
    }
    await db.into(db.animeCustomEpisodeRows).insertOnConflictUpdate(
          AnimeCustomEpisodeRowsCompanion.insert(
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
  Map<String, dynamic> toSyncPayload(CustomEpisode episode) {
    _validateKind(episode);
    return {
      'catalog_ref': episode.seriesRef.toJson(),
      'season_number': episode.seasonNumber,
      'episode_number': episode.episodeNumber,
      'title': episode.title,
      if (episode.overview != null) 'overview': episode.overview,
      if (episode.airDate != null) 'air_date': episode.airDate,
      if (episode.runtimeMinutes != null)
        'runtime_minutes': episode.runtimeMinutes,
      if (episode.stillImageUrl != null)
        'still_image_url': episode.stillImageUrl,
      if (episode.localImagePath != null)
        'local_image_path': episode.localImagePath,
      if (episode.thumbnailImageUrl != null)
        'thumbnail_image_url': episode.thumbnailImageUrl,
    };
  }

  @override
  CustomEpisode fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final seriesRef = _seriesRefFromPayload(payload);
    if (seriesRef.kind != kind) {
      throw ArgumentError.value(
        seriesRef.kind,
        'payload.catalog_ref.kind',
        'Expected Anime custom episode',
      );
    }
    return CustomEpisode(
      id: id,
      seriesRef: seriesRef,
      seasonNumber: _requiredInt(payload['season_number'], 'season_number'),
      episodeNumber: _requiredInt(payload['episode_number'], 'episode_number'),
      title: _requiredString(payload['title'], 'title'),
      overview: payload['overview'] as String?,
      airDate: payload['air_date'] as String?,
      runtimeMinutes: _optionalInt(payload['runtime_minutes']),
      stillImageUrl: payload['still_image_url'] as String?,
      localImagePath: payload['local_image_path'] as String?,
      thumbnailImageUrl: payload['thumbnail_image_url'] as String?,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
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

  CustomEpisode _fromRow(AnimeCustomEpisodeRow row) {
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

  void _validateKind(CustomEpisode episode) {
    if (episode.seriesRef.kind != kind) {
      throw ArgumentError.value(
        episode.seriesRef.kind,
        'episode.seriesRef.kind',
        'Expected Anime custom episode',
      );
    }
  }

  CatalogEntityRef _seriesRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException(
        'Anime custom episode is missing catalog_ref',
      );
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _formatDate(DateTime? value) => value?.toIso8601String();

String _requiredString(Object? value, String field) {
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Anime custom episode has invalid $field');
}

int _requiredInt(Object? value, String field) {
  final parsed = _optionalInt(value);
  if (parsed != null) return parsed;
  throw FormatException('Anime custom episode has invalid $field');
}

int? _optionalInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
