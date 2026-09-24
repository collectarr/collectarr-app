import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildMangaManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! MangaAddManualDraft || title.trim().isEmpty) return null;
  if (mangaAddSchema.validate?.call(draft) != null) return null;
  final id = 'manual-manga-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = mangaMetadataFromManualCatalogFormValues(
    values: draft.values,
    id: id,
    title: title,
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.manga),
      kindMetadata: metadata,
    ),
  );
}
