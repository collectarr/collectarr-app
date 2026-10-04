import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
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
  final values = draft.values..title = title.trim();
  final metadata = comicCatalogItemFromFormValues(
    original: ComicCatalogItem(
      id: ComicCatalogItemId(id),
      title: title.trim(),
    ),
    values: values,
    externalLinks: [
      for (final link in draft.externalLinks)
        if (link.urlController.text.trim().isNotEmpty) link.toModel(),
    ],
    creators: [
      for (final creator in draft.creators)
        if (creator.nameController.text.trim().isNotEmpty)
          ComicCreator.fromValue(creator.toMap()),
    ],
    characters: [
      for (final character in draft.characters)
        if (character.nameController.text.trim().isNotEmpty)
          ComicCharacter.fromValue(character.toMap()),
    ],
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.comic),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal,
    ),
  );
}

/// Serializes this kind's typed manual catalog model for Core review.
///
/// Core projects the supplied object onto the recognized flattened fields for
/// this kind, so this mapper does not maintain a second field denylist.
Map<String, Object?>? buildComicManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildComicManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.kindData),
  );
}
