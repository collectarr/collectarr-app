import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';

CatalogSearchCandidate? buildMovieManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! MovieAddManualDraft || title.trim().isEmpty) return null;
  if (movieAddSchema.validate?.call(draft) != null) return null;

  final id = 'manual-movie-${DateTime.now().microsecondsSinceEpoch}';
  final values = draft.values;
  final releaseTitle = _text(values.releaseTitle);
  final releaseDateParts = _releaseDateParts(values);
  final directors = _split(values.directors);
  final characters = _split(values.characters);
  final common = CatalogCommonDto(
    title: title.trim(),
    sortKey: _text(values.sortTitle),
    synopsis: _text(values.workDescription),
    coverImageUrl: _text(values.coverImageUrl),
    releaseDate: releaseDateParts?.asDateTime,
    releaseDateParts: releaseDateParts,
    releaseYear: releaseDateParts?.year,
  );
  final item = CatalogItemDto.raw(
    id: id,
    mediaKind: CatalogMediaKind.movie,
    common: common,
    payload: {
      if (releaseTitle != null) 'edition_title': releaseTitle,
      if (_text(values.subtitle) case final value?) 'subtitle': value,
      if (_text(values.format) case final value?) 'physical_format': value,
      if (_text(values.region) case final value?) 'country': value,
      if (_text(values.distributor) case final value?) 'publisher': value,
      if (_text(values.language) case final value?) 'language': value,
      if (_text(values.ageRating) case final value?) 'age_rating': value,
      if (_text(values.audienceRating) case final value?)
        'audience_rating': value,
      if (values.runtimeMinutes case final value?) 'runtime_minutes': value,
      if (values.genres.isNotEmpty) 'genres': List<String>.of(values.genres),
      if (_text(values.barcode) case final value?) 'barcode': value,
      if (_text(values.itemNumber) case final value?) 'item_number': value,
      if (_text(values.variant) case final value?) 'variant_name': value,
      if (directors.isNotEmpty)
        'contributors': [
          for (final director in directors)
            {'name': director, 'role': 'director'},
        ],
      if (characters.isNotEmpty) 'characters': characters,
    },
  );
  return CatalogSearchCandidate.fromItem(item);
}

/// Serializes the selected flat Catalog Item fields for Core review.
Map<String, Object?>? buildMovieManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildMovieManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.payload)
      ..remove('id')
      ..remove('kind'),
  );
}

String? _text(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

PartialDate? _releaseDateParts(MovieCatalogFormValues values) {
  final date = values.releaseDate;
  final year = values.releaseYear;
  if (date == null && (year == null || year < 1)) return null;
  if (date == null) return PartialDate(year: year);
  return PartialDate(
    year: year != null && year > 0 ? year : date.year,
    month: date.month,
    day: date.day,
  );
}

List<String> _split(String value) => value
    .split(RegExp(r'[,;\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
