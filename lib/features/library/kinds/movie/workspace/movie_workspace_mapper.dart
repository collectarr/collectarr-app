import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

final class MovieWorkspaceMapper {
  const MovieWorkspaceMapper._();

  static MovieMedia fromCatalogItem(CatalogItem item) {
    final payload = item.toSyncPayload();
    final video = payload['video'];
    final videoPayload = video is Map ? video : const <String, dynamic>{};
    final releases = item.editions
        .map((edition) => _releasePayload(item.id, edition))
        .toList(growable: false);
    final trailerUrls = item.trailerUrls
        .map((trailer) => trailer.toJson())
        .toList(growable: false);

    return MovieMedia.fromJson({
      ...payload,
      'id': item.id,
      'kind': 'movie',
      'title': item.title,
      if (item.synopsis != null) 'description': item.synopsis,
      if (payload['original_language'] == null && payload['language'] != null)
        'original_language': payload['language'],
      if (payload['runtime_minutes'] == null &&
          videoPayload['runtime_minutes'] != null)
        'runtime_minutes': videoPayload['runtime_minutes'],
      if (payload['contributions'] == null && payload['creators'] is List)
        'contributions': payload['creators'],
      'releases': releases,
      'trailer_urls': trailerUrls,
    });
  }

  static Map<String, dynamic> _releasePayload(
    String workId,
    CatalogEditionDto edition,
  ) {
    final metadata = edition.metadata ?? const <String, dynamic>{};
    final audioTracks = metadata['audio_tracks']?.toString();
    final subtitles = metadata['subtitles']?.toString();
    final media = [
      for (var index = 0; index < edition.discs.length; index++)
        {
          'id':
              '${edition.id}:media:${edition.discs[index].discNumber ?? index + 1}',
          'release_id': edition.id,
          'media_number': edition.discs[index].discNumber ?? index + 1,
          'media_type': 'disc',
          if (edition.discs[index].name != null)
            'title': edition.discs[index].name,
          if (audioTracks != null) 'audio_tracks': audioTracks,
          if (subtitles != null) 'subtitles': subtitles,
        },
    ];

    return {
      ...edition.toJson(),
      'id': edition.id,
      'kind': 'movie',
      'work_id': workId,
      'release_title': edition.title,
      'media': media,
    };
  }
}
