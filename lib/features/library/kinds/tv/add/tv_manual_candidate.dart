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
  final year = int.tryParse(draft.yearController.text.trim());
  final season = int.tryParse(draft.numberController.text.trim());
  final releaseDate = _date(draft.releaseDateController.text) ??
      (year == null ? null : DateTime.utc(year));
  final id = 'manual-tv-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = TvSeriesMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'series_title': title.trim(),
    if (releaseDate != null) 'first_air_date': releaseDate.toIso8601String(),
    if (season != null) 'season_number': season,
    if (_text(draft.publisherController.text) case final value?) ...{
      'network': value,
      'publisher': value,
    },
    if (_text(draft.barcodeController.text) case final value?) 'barcode': value,
    if (_text(draft.variantController.text) case final value?) 'variant': value,
    if (_text(draft.physicalFormatLabelController.text) case final value?)
      'physical_format_label': value,
    if (_text(draft.coverController.text) case final value?)
      'cover_image_url': value,
    if (_text(draft.synopsisController.text) case final value?)
      'synopsis': value,
    if (_text(draft.genresEditController.text) case final value?)
      'genres': _split(value),
    if (_text(draft.ageRatingController.text) case final value?)
      'content_rating': value,
    if (_text(draft.languageController.text) case final value?)
      'original_language': value,
    if (_text(draft.countryController.text) case final value?) 'country': value,
    if (_text(draft.editionTitleController.text) case final value?)
      'edition_title': value,
    if (_text(draft.creatorsController.text) case final value?)
      'creators': _split(value),
    if (_text(draft.charactersController.text) case final value?)
      'characters': _split(value),
  });
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.tv),
      kindMetadata: metadata,
    ),
  );
}

String? _text(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? _date(String value) =>
    value.trim().isEmpty ? null : DateTime.tryParse(value.trim());

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .toSet()
    .toList(growable: false);
