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
  final id = 'manual-anime-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = AnimeMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'native_title': _text(draft.nativeTitleController.text),
    'romaji_title': _text(draft.romajiTitleController.text),
    'english_title': _text(draft.englishTitleController.text),
    'alternate_titles': _split(draft.alternateTitlesController.text),
    'format': _text(draft.formatController.text),
    'season': _text(draft.seasonController.text),
    'season_year': _integer(draft.seasonYearController.text),
    'episode_count': _integer(draft.episodeCountController.text),
    'episode_runtime_minutes': _integer(draft.episodeRuntimeController.text),
    'airing_status': _text(draft.airingStatusController.text),
    'source_material': _text(draft.sourceMaterialController.text),
    'start_date': _date(draft.startDateController.text),
    'end_date': _date(draft.endDateController.text),
    'studios': _split(draft.studioController.text),
    'producers': _split(draft.producersController.text),
    'licensors': _split(draft.licensorsController.text),
    'themes': _split(draft.themesController.text),
    'series_title': title.trim(),
    'item_number': _text(draft.numberController.text),
    'publisher': _text(draft.publisherController.text),
    'barcode': _text(draft.barcodeController.text),
    'variant': _text(draft.variantController.text),
    'physical_format_label': _text(draft.physicalFormatLabelController.text),
    'edition_title': _text(draft.editionTitleController.text),
    'release_date': _date(draft.releaseDateController.text),
    'cover_image_url': _text(draft.coverController.text),
    'back_cover_image_url': _text(draft.backCoverController.text),
    'creators': _split(draft.creatorsController.text),
    'characters': _split(draft.charactersController.text),
    'synopsis': _text(draft.synopsisController.text),
    'genres': _split(draft.genresEditController.text),
    'age_rating': _text(draft.ageRatingController.text),
    'language': _text(draft.languageController.text),
    'country': _text(draft.countryController.text),
    'year': _integer(draft.yearController.text),
  });
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.anime),
      kindMetadata: metadata,
    ),
  );
}

String? _text(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int? _integer(String value) => int.tryParse(value.trim());

String? _date(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final parsed = DateTime.tryParse(trimmed);
  return parsed?.toIso8601String();
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .toSet()
    .toList(growable: false);
