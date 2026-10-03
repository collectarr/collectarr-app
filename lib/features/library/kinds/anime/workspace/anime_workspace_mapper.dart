import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Builds the Anime workspace projection from the flat kind document.
final class AnimeWorkspaceMapper {
  const AnimeWorkspaceMapper._();

  static AnimeMedia fromCatalogItem(CatalogItemDto item) {
    final basePayload = Map<String, dynamic>.from(item.kindData);
    final metadata = AnimeMetadata.fromJson(basePayload);
    final payload = <String, dynamic>{
      ...basePayload,
      'id': item.id,
      'kind': 'anime',
      'title': metadata.title,
      if (basePayload['description'] == null && metadata.synopsis != null)
        'description': metadata.synopsis,
      if (basePayload['anime_type'] == null)
        'anime_type': metadata.format.label,
      if (basePayload['original_air_date'] == null &&
          metadata.startDate != null)
        'original_air_date': metadata.startDate!.toIso8601String(),
      if (basePayload['end_date'] == null && metadata.endDate != null)
        'end_date': metadata.endDate!.toIso8601String(),
      if (basePayload['original_language'] == null)
        'original_language': metadata.language,
      if (basePayload['episode_count'] == null && metadata.episodeCount != null)
        'episode_count': metadata.episodeCount,
      if (basePayload['status'] == null) 'status': metadata.airingStatus.name,
      if (basePayload['contributions'] == null && metadata.creators.isNotEmpty)
        'contributions': metadata.creators,
      'media': [for (final media in metadata.media) media.toJson()],
    };
    return AnimeMedia.fromJson(payload);
  }
}
