import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

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
    externalLinks: [
      for (final (index, link) in draft.externalLinks
          .where((link) => link.urlController.text.trim().isNotEmpty)
          .indexed)
        MangaExternalLink(
          url: link.urlController.text.trim(),
          title: _optional(link.titleController.text),
          label: _optional(link.titleController.text),
          description: _optional(link.descriptionController.text),
          kind: 'external',
          linkType: 'external',
          position: index + 1,
        ),
    ],
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      ref: CatalogItemRef(kind: CatalogMediaKind.manga, id: id),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal,
    ),
  );
}

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

/// Serializes this kind's typed manual catalog model for Core review.
///
/// Core projects the supplied object onto the recognized flattened fields for
/// this kind, so this mapper does not maintain a second field denylist.
Map<String, Object?>? buildMangaManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildMangaManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.kindData),
  );
}
