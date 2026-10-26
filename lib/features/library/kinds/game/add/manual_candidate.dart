import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/game/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/schema.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';

CatalogSearchCandidate? buildGameManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! GameAddManualDraft || title.trim().isEmpty) return null;
  if (gameAddSchema.validate?.call(draft) != null) return null;
  final id = 'manual-game-${DateTime.now().microsecondsSinceEpoch}';
  final metadata = gameMetadataFromManualFormValues(
    values: draft.values,
    id: id,
    title: title,
    externalLinks: [
      ..._links(draft.externalLinks, kind: 'external'),
      ..._links(draft.trailers, kind: 'trailer'),
    ],
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      ref: CatalogItemRef(kind: CatalogMediaKind.game, id: id),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal,
    ),
  );
}

List<GameCatalogLink> _links(
  List<LibraryExternalLinkDraftRow> rows, {
  required String kind,
}) =>
    [
      for (final (index, link) in rows
          .where((link) => link.urlController.text.trim().isNotEmpty)
          .indexed)
        GameCatalogLink(
          url: link.urlController.text.trim(),
          label: _optional(link.titleController.text),
          title: _optional(link.titleController.text),
          description: _optional(link.descriptionController.text),
          kind: kind,
          linkType: kind,
          position: index + 1,
        ),
    ];

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

/// Serializes this kind's typed manual catalog model for Core review.
///
/// Core projects the supplied object onto the recognized flattened fields for
/// this kind, so this mapper does not maintain a second field denylist.
Map<String, Object?>? buildGameManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildGameManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.kindData),
  );
}
