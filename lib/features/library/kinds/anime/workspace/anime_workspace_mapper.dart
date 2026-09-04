import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

/// Builds the Anime-owned workspace graph from the catalog snapshot.
///
/// The catalog cache still contains the legacy [AnimeMetadata] payload. This
/// boundary converts that payload into typed Anime media and release values;
/// the legacy metadata remains available to fields that have not migrated yet.
final class AnimeWorkspaceMapper {
  const AnimeWorkspaceMapper._();

  static AnimeMedia fromCatalogItem(LibraryMetadataItem item) {
    final basePayload = Map<String, dynamic>.from(item.toSyncPayload());
    final metadata = item.kindMetadata;
    final payload = <String, dynamic>{
      ...basePayload,
      'id': item.id,
      'kind': 'anime',
      'title': item.title,
      if (basePayload['description'] == null && item.synopsis != null)
        'description': item.synopsis,
      if (metadata is AnimeMetadata) ...{
        if (basePayload['anime_type'] == null)
          'anime_type': metadata.format.label,
        if (basePayload['original_air_date'] == null &&
            metadata.startDate != null)
          'original_air_date': metadata.startDate!.toIso8601String(),
        if (basePayload['end_date'] == null && metadata.endDate != null)
          'end_date': metadata.endDate!.toIso8601String(),
        if (basePayload['original_language'] == null)
          'original_language': metadata.language,
        if (basePayload['episode_count'] == null &&
            metadata.episodeCount != null)
          'episode_count': metadata.episodeCount,
        if (basePayload['status'] == null) 'status': metadata.airingStatus.name,
        if (basePayload['contributions'] == null &&
            metadata.creators.isNotEmpty)
          'contributions': metadata.creators,
      },
      'releases': item.editions.isNotEmpty
          ? [
              for (final edition in item.editions)
                _releasePayload(item.id, edition),
            ]
          : (basePayload['releases'] is Iterable
              ? basePayload['releases']
              : const <dynamic>[]),
    };
    return AnimeMedia.fromJson(payload);
  }

  static Map<String, dynamic> _releasePayload(
    String seriesId,
    CatalogEditionDto edition,
  ) {
    final metadata = edition.metadata ?? const <String, dynamic>{};
    return {
      ...edition.toJson(),
      'id': edition.id,
      'kind': 'anime',
      'series_id': seriesId,
      'release_title': edition.title,
      if (edition.physicalFormatLabel != null)
        'format': edition.physicalFormatLabel,
      if (edition.region != null) 'region_code': edition.region,
      if (edition.upc != null) 'barcode': edition.upc,
      if (edition.discs.isNotEmpty) 'media_count': edition.discs.length,
      if (metadata['audio_tracks'] is Iterable)
        'audio_tracks': metadata['audio_tracks'],
      if (metadata['subtitles'] is Iterable) 'subtitles': metadata['subtitles'],
    };
  }
}
