import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

CatalogSearchCandidate? buildBoardgameManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! BoardgameAddManualDraft || title.trim().isEmpty) return null;
  if (boardGameAddSchema.validate?.call(draft) != null) return null;
  final id = 'manual-boardgame-${DateTime.now().microsecondsSinceEpoch}';
  final BoardGameMetadata metadata = boardGameMetadataFromManualFormValues(
    values: draft.values,
    title: title,
    externalLinks: [
      for (final (index, link) in draft.externalLinks
          .where((link) => link.urlController.text.trim().isNotEmpty)
          .indexed)
        BoardGameLink(
          url: link.urlController.text.trim(),
          label: _nullable(link.titleController.text),
          title: _nullable(link.titleController.text),
          description: _nullable(link.descriptionController.text),
          position: index + 1,
        ),
    ],
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      ref: CatalogItemRef(kind: CatalogMediaKind.boardgame, id: id),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal,
    ),
  );
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

/// Serializes this kind's typed manual catalog model for Core review.
///
/// Core projects the supplied object onto the recognized flattened fields for
/// this kind, so this mapper does not maintain a second field denylist.
Map<String, Object?>? buildBoardgameManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildBoardgameManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.kindData),
  );
}
