import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_adapters.dart';

CatalogSearchCandidate? buildBookManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! BookAddManualDraft || title.trim().isEmpty) return null;
  if (bookAddSchema.validate?.call(draft) != null) return null;
  final id = 'manual-book-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = bookMetadataFromManualFormValues(
    values: draft.values,
    id: id,
    title: title,
  ).copyWith(
    externalLinks: [
      for (final (index, link) in draft.externalLinks
          .where((link) => link.row.urlController.text.trim().isNotEmpty)
          .indexed)
        link.toModel(index + 1),
    ],
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      ref: CatalogItemRef(kind: CatalogMediaKind.book, id: id),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal,
    ),
  );
}

/// Serializes this kind's typed manual catalog model for Core review.
///
/// Core projects the supplied object onto the recognized flattened fields for
/// this kind, so this mapper does not maintain a second field denylist.
Map<String, Object?>? buildBookManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildBookManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.kindData),
  );
}
