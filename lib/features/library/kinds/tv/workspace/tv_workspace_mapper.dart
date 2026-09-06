import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Builds the TV-owned workspace graph from the catalog snapshot.
///
/// Translates the catalog snapshot into the typed TV domain graph used by
/// workspace fields and hierarchy code.
final class TvWorkspaceMapper {
  const TvWorkspaceMapper._();

  static TvSeries fromCatalogItem(CatalogItem item) {
    final basePayload = Map<String, dynamic>.from(item.toSyncPayload());
    final metadata = item.kindMetadata is TvSeriesMetadata
        ? item.kindMetadata as TvSeriesMetadata
        : null;

    final payload = <String, dynamic>{
      ...basePayload,
      'id': item.id,
      'kind': 'tv',
      'title': item.title,
      if (basePayload['description'] == null && item.synopsis != null)
        'description': item.synopsis,
      if (metadata?.firstAirDate != null &&
          basePayload['original_air_date'] == null)
        'original_air_date': metadata!.firstAirDate!.toIso8601String(),
      if (metadata?.lastAirDate != null && basePayload['end_date'] == null)
        'end_date': metadata!.lastAirDate!.toIso8601String(),
      if (metadata?.network != null && basePayload['network'] == null)
        'network': metadata!.network,
      if (metadata?.originalLanguage != null &&
          basePayload['original_language'] == null)
        'original_language': metadata!.originalLanguage,
      if (metadata?.seasonCount != null && basePayload['season_count'] == null)
        'season_count': metadata!.seasonCount,
      if (metadata?.episodeCount != null &&
          basePayload['episode_count'] == null)
        'episode_count': metadata!.episodeCount,
      if (metadata?.status != null && basePayload['status'] == null)
        'status': metadata!.status,
      if (metadata?.seasons.isNotEmpty == true)
        'seasons': [
          for (final season in metadata!.seasons)
            _seasonPayload(item.id, season),
        ],
      if (metadata?.releases.isNotEmpty == true)
        'releases': [
          for (final release in metadata!.releases)
            _releasePayload(item.id, release),
        ],
      if (basePayload['contributions'] == null && metadata != null)
        'contributions': [
          ...metadata.cast.map((credit) => _creditPayload(credit, 'cast')),
          ...metadata.crew.map((credit) => _creditPayload(credit, 'crew')),
          ...metadata.creators,
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

  static Map<String, dynamic> _releasePayload(
    String seriesId,
    TvPhysicalReleaseMetadata release,
  ) {
    final media = [
      for (var number = 1; number <= (release.discCount ?? 0); number++)
        {
          'id': '${release.id}:media:$number',
          'release_id': release.id,
          'media_number': number,
          'media_type': 'disc',
          'title': 'Disc $number',
        },
    ];
    return {
      ...release.toJson(),
      'id': release.id,
      'series_id': seriesId,
      'title': release.title,
      if (release.region != null) 'region_code': release.region,
      if (release.barcode != null) 'sku': release.barcode,
      if (release.packaging != null) 'case_type': release.packaging,
      if (release.discCount != null) 'media_count': release.discCount,
      if (release.audioTracks.isNotEmpty) 'language_audio': release.audioTracks,
      if (release.subtitles.isNotEmpty) 'language_subtitles': release.subtitles,
      'media': media,
    };
  }

  static Map<String, dynamic> _creditPayload(
    TvPersonCredit credit,
    String fallbackRole,
  ) =>
      {
        'name': credit.name,
        'role': credit.role ?? fallbackRole,
        if (credit.character != null) 'character_name': credit.character,
        if (credit.imageUrl != null) 'image_url': credit.imageUrl,
      };
}
