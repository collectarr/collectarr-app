import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';

/// TV-owned custom episode sync boundary.
final class TvCustomEpisodeCodec implements CustomEpisodeSyncCodec {
  const TvCustomEpisodeCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Future<void> applySyncPayload(
    LocalDatabase db, {
    required JsonMap payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final episode = _fromSyncPayload(
      payload: payload,
      id: id,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
    return TvTrackingRepository(db).upsertCustomEpisode(episode);
  }

  @override
  Future<CustomEpisodeSyncRecord?> readSyncRecord(
    LocalDatabase db,
    String id,
  ) async {
    final episode = await TvTrackingRepository(db).findCustomEpisodeById(
      TvEpisodeId(id),
    );
    if (episode == null) return null;
    return CustomEpisodeSyncRecord(
      payload: _toSyncPayload(episode),
      isDeleted: episode.isDeleted,
    );
  }

  JsonMap toSyncPayload(TvCustomEpisode episode) => _toSyncPayload(episode);

  TvCustomEpisode fromSyncPayload({
    required JsonMap payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) =>
      _fromSyncPayload(
        payload: payload,
        id: id,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  TvCustomEpisode _fromSyncPayload({
    required JsonMap payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final seriesRef = _catalogRef(payload);
    if (seriesRef.mediaKind != kind) {
      throw ArgumentError.value(
        seriesRef.mediaKind,
        'payload.catalog_ref.kind',
        'Expected TV custom episode',
      );
    }
    return TvCustomEpisode(
      id: TvEpisodeId(id),
      seriesId: TvSeriesId(seriesRef.id),
      seasonNumber: _requiredInt(payload['season_number'], 'season_number'),
      episodeNumber: _requiredInt(payload['episode_number'], 'episode_number'),
      title: _requiredString(payload['title'], 'title'),
      description:
          payload['description'] as String? ?? payload['overview'] as String?,
      airDate: _date(payload['air_date']),
      runtimeMinutes: _optionalInt(payload['runtime_minutes']),
      stillImageUrl: payload['still_image_url'] as String?,
      localImagePath: payload['local_image_path'] as String?,
      thumbnailImageUrl: payload['thumbnail_image_url'] as String?,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  JsonMap _toSyncPayload(TvCustomEpisode episode) {
    return {
      'catalog_ref': CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityTypeId.root,
        id: episode.seriesId.value,
      ).toJson(),
      'season_number': episode.seasonNumber,
      'episode_number': episode.episodeNumber,
      'title': episode.title,
      if (episode.description != null) 'description': episode.description,
      if (episode.airDate != null)
        'air_date': episode.airDate!.toUtc().toIso8601String(),
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

  CatalogEntityRef _catalogRef(JsonMap payload) {
    final raw = payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException('TV custom episode is missing catalog_ref');
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }
}

String _requiredString(Object? value, String field) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw FormatException('TV custom episode has invalid $field');
}

int _requiredInt(Object? value, String field) {
  final parsed = _optionalInt(value);
  if (parsed != null) return parsed;
  throw FormatException('TV custom episode has invalid $field');
}

int? _optionalInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) => DateTime.tryParse(value?.toString() ?? '');
