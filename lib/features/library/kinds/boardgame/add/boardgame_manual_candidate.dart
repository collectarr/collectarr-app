import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildBoardgameManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! BoardgameAddManualDraft || title.trim().isEmpty) return null;
  final year = int.tryParse(draft.yearController.text.trim());
  final id = 'manual-boardgame-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = BoardGameMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'year_published': year,
    'item_number': _text(draft.numberController.text),
    'publisher': _text(draft.publisherController.text),
    'barcode': _text(draft.barcodeController.text),
    'variant': _text(draft.variantController.text),
    'physical_format_label': _text(draft.physicalFormatLabelController.text),
    'cover_image_url': _text(draft.coverController.text),
    'back_cover_image_url': _text(draft.backCoverController.text),
    'designers': _split(draft.creatorsController.text),
    'characters': _split(draft.charactersController.text),
    'synopsis': _text(draft.synopsisController.text),
    'categories': _split(draft.genresEditController.text),
    'minimum_age': int.tryParse(draft.ageRatingController.text.trim()),
    'languages': _split(draft.languageController.text),
    'country': _text(draft.countryController.text),
    'edition_title': _text(draft.editionTitleController.text),
    'release_date': _date(draft.releaseDateController.text),
  });
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity:
          LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.boardgame),
      kindMetadata: metadata,
    ),
  );
}

String? _text(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _date(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return DateTime.tryParse(trimmed)?.toIso8601String();
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .toSet()
    .toList(growable: false);
