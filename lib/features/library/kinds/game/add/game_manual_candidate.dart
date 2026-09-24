import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildGameManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! GameAddManualDraft || title.trim().isEmpty) return null;
  if (gameAddSchema.validate?.call(draft) != null) return null;
  final year = int.tryParse(draft.yearController.text.trim());
  final releaseDate = _date(draft.releaseDateController.text) ??
      (year == null ? null : DateTime.utc(year).toIso8601String());
  final id = 'manual-game-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = GameCatalogMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'platform': _text(draft.platformController.text),
    'platforms': _split(draft.platformController.text),
    'release_region': _text(draft.regionController.text),
    'release_date': releaseDate,
    'publisher': _text(draft.publisherController.text),
    'barcode': _text(draft.barcodeController.text),
    'variant': _text(draft.variantController.text),
    'physical_format_label': _text(draft.physicalFormatLabelController.text),
    'cover_image_url': _text(draft.coverController.text),
    'back_cover_image_url': _text(draft.backCoverController.text),
    'developers': _split(draft.creatorsController.text),
    'characters': _split(draft.charactersController.text),
    'synopsis': _text(draft.synopsisController.text),
    'genres': _split(draft.genresEditController.text),
    'age_rating': _text(draft.ageRatingController.text),
    'languages': _split(draft.languageController.text),
    'country': _text(draft.countryController.text),
    'edition': _text(draft.editionTitleController.text),
    'item_number': _text(draft.numberController.text),
  });
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.game),
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
