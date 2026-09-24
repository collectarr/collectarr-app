import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildComicManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! ComicAddManualDraft || title.trim().isEmpty) return null;
  if (comicAddSchema.validate?.call(draft) != null) return null;
  final id = 'manual-comic-${DateTime.now().microsecondsSinceEpoch}';
  final values = draft.values..seriesTitle = title.trim();
  final metadata = comicMediaFromFormValues(
    original: ComicMedia(
      id: ComicMediaId(id),
      title: title.trim(),
    ),
    values: values,
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.comic),
      kindMetadata: metadata,
    ),
  );
}
