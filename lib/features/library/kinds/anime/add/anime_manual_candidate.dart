import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildAnimeManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! AnimeAddManualDraft || title.trim().isEmpty) return null;
  if (animeAddSchema.validate?.call(draft) != null) return null;

  final media = draft.media;
  final release = draft.release;
  final id = 'manual-anime-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = AnimeMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'native_title': _nullable(media.nativeTitle),
    'romaji_title': _nullable(media.romajiTitle),
    'english_title': _nullable(media.englishTitle),
    'alternate_titles': media.alternateTitles,
    'format': _nullable(media.animeType),
    'season': _nullable(media.season),
    'season_year': media.seasonYear,
    'episode_count': media.episodeCount,
    'episode_runtime_minutes': media.episodeRuntimeMinutes,
    'airing_status': _nullable(media.status),
    'source_material': _nullable(media.sourceMaterial),
    'genres': media.genres,
    'themes': media.themes,
    'country': _nullable(media.country),
    'language': _nullable(media.originalLanguage),
    'start_date': media.startDate?.toIso8601String(),
    'end_date': media.endDate?.toIso8601String(),
    'studios': media.studios,
    'producers': media.producers,
    'licensors': media.licensors,
    'synopsis': _nullable(media.description),
    'cover_image_url': _nullable(media.coverImageUrl),
    'creators': [
      for (final name in media.creators) {'name': name, 'role': 'creator'},
    ],
    'characters': media.characters,
    'title_extension': _nullable(media.romajiTitle),
    'physical_format_label': _nullable(release.format),
    'edition_title': _nullable(release.title),
    'publisher': _nullable(release.publisher),
    'distributor': _nullable(release.distributor),
    'barcode': _nullable(release.barcode),
    'region': _nullable(release.region),
    'release_date': release.releaseDate?.toIso8601String(),
    'variant': _nullable(release.variant),
    'editions': release.title.trim().isEmpty
        ? const <Map<String, dynamic>>[]
        : [
            {
              'id': '$id-release',
              'title': release.title.trim(),
              'format': _nullable(release.format),
              'physical_format': _nullable(release.format),
              'physical_format_label': _nullable(release.format),
              'region': _nullable(release.region),
              'language': _nullable(release.language),
              'release_date': release.releaseDate?.toIso8601String(),
              'publisher': _nullable(release.publisher),
              'distributor': _nullable(release.distributor),
              'upc': _nullable(release.barcode),
              'metadata': {
                'media_count': release.mediaCount,
                'audio_tracks': release.audioTracks,
                'subtitles': release.subtitles,
                'description': _nullable(release.description),
                'cover_image_url': _nullable(release.coverImageUrl),
                'variant': _nullable(release.variant),
              },
            },
          ],
  });

  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.anime),
      kindMetadata: metadata,
    ),
  );
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
