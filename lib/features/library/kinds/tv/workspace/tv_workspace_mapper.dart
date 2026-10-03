import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Projects a flat TV catalog document into the active workspace view model.
final class TvWorkspaceMapper {
  const TvWorkspaceMapper._();

  static TvSeries fromCatalogItem(CatalogItemDto item) {
    final metadataPayload = item.kindData;
    final basePayload = Map<String, dynamic>.from(metadataPayload);
    final metadata = TvSeriesMetadata.fromJson(metadataPayload);

    final payload = <String, dynamic>{
      ...basePayload,
      'id': item.id,
      'kind': 'tv',
      'title': metadata.title,
      if (basePayload['description'] == null && metadata.synopsis != null)
        'description': metadata.synopsis,
      if (metadata.firstAirDate != null &&
          basePayload['original_air_date'] == null)
        'original_air_date': metadata.firstAirDate!.toIso8601String(),
      if (metadata.lastAirDate != null && basePayload['end_date'] == null)
        'end_date': metadata.lastAirDate!.toIso8601String(),
      if (metadata.network != null && basePayload['network'] == null)
        'network': metadata.network,
      if (basePayload['original_language'] == null)
        'original_language': metadata.originalLanguage,
      if (metadata.seasonCount != null && basePayload['season_count'] == null)
        'season_count': metadata.seasonCount,
      if (metadata.episodeCount != null && basePayload['episode_count'] == null)
        'episode_count': metadata.episodeCount,
      if (metadata.status != null && basePayload['status'] == null)
        'status': metadata.status,
      'media': [for (final media in metadata.media) media.toJson()],
      if (metadata.seasons.isNotEmpty)
        'seasons': [
          for (final season in metadata.seasons)
            _seasonPayload(item.id, season),
        ],
      if (basePayload['contributions'] == null)
        'contributions': [
          ...metadata.creators.map((credit) => _creditPayload(credit)),
        ],
    };

    return TvSeries.fromJson(payload);
  }

  static Map<String, dynamic> _seasonPayload(
    String seriesId,
    TvSeasonMetadata season,
  ) {
    final seasonId = '$seriesId:season:${season.seasonNumber}';
    return {
      'id': seasonId,
      'series_id': seriesId,
      ...season.toJson(),
      'episodes': [
        for (final episode in season.episodes)
          {
            'id': '$seasonId:episode:${episode.number}',
            'series_id': seriesId,
            'season_id': seasonId,
            ...episode.toJson(),
            'episode_number': episode.number,
          },
      ],
    };
  }

  static Map<String, dynamic> _creditPayload(TvPersonCredit credit) => {
        'name': credit.name,
        if (credit.role != null) 'role': credit.role,
        if (credit.character != null) 'character_name': credit.character,
        if (credit.imageUrl != null) 'image_url': credit.imageUrl,
      };
}
