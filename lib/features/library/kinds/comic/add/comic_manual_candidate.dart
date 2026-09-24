import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildComicManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! ComicAddManualDraft || title.trim().isEmpty) return null;
  if (comicAddSchema.validate?.call(draft) != null) return null;
  final issueNumber = _text(draft.numberController.text);
  final year = int.tryParse(draft.yearController.text.trim());
  final id = 'manual-comic-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = ComicMedia.fromJson({
    'id': id,
    'title': title.trim(),
    'series_title': title.trim(),
    'issue_number': issueNumber,
    'item_number': issueNumber,
    'publisher': _text(draft.publisherController.text),
    'release_date': year == null ? null : DateTime.utc(year).toIso8601String(),
    'barcode': _text(draft.barcodeController.text),
    'variant': _text(draft.variantController.text),
    'physical_format_label': _text(draft.physicalFormatLabelController.text),
    'cover_image_url': _text(draft.coverController.text),
  });
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.comic),
      kindMetadata: metadata,
    ),
  );
}

String? _text(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
