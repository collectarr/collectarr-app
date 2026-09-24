import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildTvManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! TvAddManualDraft || title.trim().isEmpty) return null;
  if (tvAddSchema.validate?.call(draft) != null) return null;

  final series = draft.series;
  final release = draft.release;
  final firstAirDate = series.originalAirDate ??
      (draft.firstAirYear == null ? null : DateTime.utc(draft.firstAirYear!));
  final releaseTitle = release.title.trim();
  final id = 'manual-tv-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = TvSeriesMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'series_title': title.trim(),
    'sort_title': _nullable(series.sortTitle),
    'synopsis': _nullable(series.description),
    if (firstAirDate != null) 'first_air_date': firstAirDate.toIso8601String(),
    if (series.endDate != null)
      'last_air_date': series.endDate!.toIso8601String(),
    'network': _nullable(series.network),
    'streaming_service': _nullable(series.streamingService),
    'status': _nullable(series.status),
    'original_language': _nullable(series.originalLanguage),
    'genres': series.genres,
    'content_rating': _nullable(series.contentRating),
    if (draft.seasonNumber != null) 'season_number': draft.seasonNumber,
    if (releaseTitle.isNotEmpty)
      'editions': [
        {
          'id': '$id-release',
          'title': releaseTitle,
          'format': _nullable(release.format),
          'region': _nullable(release.region),
          'release_date': release.releaseDate?.toIso8601String(),
          'publisher': _nullable(release.publisher),
          'barcode': _nullable(release.barcode),
          'case_type': _nullable(release.caseType),
          'description': _nullable(release.description),
          'content_rating': _nullable(release.contentRating),
          'audio': release.audioLanguages,
          'subtitles': release.subtitleLanguages,
          'cover_image_url': _nullable(release.coverImageUrl),
        },
      ],
    'edition_title': releaseTitle.isEmpty ? null : releaseTitle,
    'physical_format_label': _nullable(release.format),
    'region': _nullable(release.region),
    'release_date': release.releaseDate?.toIso8601String(),
    'publisher': _nullable(release.publisher),
    'barcode': _nullable(release.barcode),
    'cover_image_url': _nullable(release.coverImageUrl),
    'creators': [
      for (final name in series.creators) {'name': name, 'role': 'creator'},
    ],
    'cast': [
      for (final name in series.characters) {'name': name}
    ],
  });

  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.tv),
      kindMetadata: metadata,
    ),
  );
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
