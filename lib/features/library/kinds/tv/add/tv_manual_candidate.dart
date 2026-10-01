import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';

CatalogSearchCandidate? buildTvManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! TvAddManualDraft || title.trim().isEmpty) return null;
  if (tvAddSchema.validate?.call(draft) != null) return null;

  final values = draft.values;
  final releaseDateParts = values.releaseDate == null
      ? null
      : PartialDate(
          year: values.releaseDate!.year,
          month: values.releaseDate!.month,
          day: values.releaseDate!.day,
        );

  return CatalogSearchCandidate.fromItem(
    CatalogItemDto.raw(
      id: 'manual-tv-${DateTime.now().microsecondsSinceEpoch}',
      mediaKind: CatalogMediaKind.tv,
      common: CatalogCommonDto(
        title: title.trim(),
        sortKey: _nullable(values.sortKey),
        originalTitle: _nullable(values.originalTitle),
        synopsis: _nullable(values.synopsis),
        coverImageUrl: _nullable(values.coverImageUrl),
        releaseDate: releaseDateParts?.asDateTime,
        releaseDateParts: releaseDateParts,
      ),
      payload: {
        if (_nullable(values.editionTitle) case final value?)
          'edition_title': value,
        if (_nullable(values.physicalFormat) case final value?)
          'physical_format': value,
        if (_nullable(values.country) case final value?) 'country': value,
        if (_nullable(values.publisher) case final value?) 'publisher': value,
        if (_nullable(values.language) case final value?) 'language': value,
        if (_nullable(values.ageRating) case final value?) 'age_rating': value,
        if (values.genres.isNotEmpty) 'genres': List<String>.of(values.genres),
        if (_nullable(values.barcode) case final value?) 'barcode': value,
        if (values.creators.isNotEmpty)
          'creators': [
            for (final name in values.creators)
              {'name': name, 'role': 'creator'},
          ],
        if (values.characters.isNotEmpty)
          'characters': List<String>.of(values.characters),
        if (_nullable(values.audioTracks) case final value?)
          'audio_tracks': value,
        if (_nullable(values.subtitles) case final value?) 'subtitles': value,
        if (values.seasonNumber case final seasonNumber?)
          'seasons': [
            {'season_number': seasonNumber},
          ],
        if (values.runtimeMinutes case final runtimeMinutes?)
          'runtime_minutes': runtimeMinutes,
        if (values.discCount case final discCount?) 'nr_discs': discCount,
        if (_nullable(values.screenRatio) case final value?)
          'screen_ratio': value,
      },
    ),
  );
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Serializes TV's flat Catalog Item fields for Core review.
Map<String, Object?>? buildTvManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildTvManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.payload)
      ..remove('id')
      ..remove('kind'),
  );
}
