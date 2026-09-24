import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

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
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.book),
      kindMetadata: metadata,
    ),
  );
}
