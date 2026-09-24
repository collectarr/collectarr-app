import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildBookManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! BookAddManualDraft || title.trim().isEmpty) return null;
  if (bookAddSchema.validate?.call(draft) != null) return null;
  final id = 'manual-book-${DateTime.now().microsecondsSinceEpoch}';
  final year = int.tryParse(draft.yearController.text.trim());
  final metadata = BookCatalogMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'subtitle': _text(draft.editionTitleController.text),
    'series_title': _text(draft.seriesGroupController.text),
    'item_number': _text(draft.numberController.text),
    'original_publisher': _text(draft.publisherController.text),
    'imprint': _text(draft.imprintController.text),
    'page_count': int.tryParse(draft.pageCountController.text.trim()),
    'authors': _split(draft.creatorsController.text),
    'characters': _split(draft.charactersController.text),
    'synopsis': _text(draft.synopsisController.text),
    'genres': _split(draft.genresEditController.text),
    'age_rating': _text(draft.ageRatingController.text),
    'language': _text(draft.languageController.text),
    'country': _text(draft.countryController.text),
    'original_publication_date': year == null ? null : '$year-01-01',
    'publication_date': _date(draft.releaseDateController.text),
    'isbn': _text(draft.barcodeController.text),
    'barcode': _text(draft.barcodeController.text),
    'variant': _text(draft.variantController.text),
    'physical_format_label': _text(draft.physicalFormatLabelController.text),
    'cover_image_url': _text(draft.coverController.text),
    'back_cover_image_url': _text(draft.backCoverController.text),
    'contributors': _split(draft.creatorsController.text),
  });
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.book),
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
