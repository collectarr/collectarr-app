import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import '../domain/game_toy_metadata.dart';
import 'game_toy_add_manual_draft.dart';

CatalogSearchCandidate? buildGameToyManualCandidate(LibraryKindAddDraft draft,
    {required String title}) {
  if (draft is! GameToyAddManualDraft || title.trim().isEmpty) return null;
  final metadata = draft.values.toMetadata(title: title, links: [
    for (final link in draft.externalLinks
        .where((link) => link.urlController.text.trim().isNotEmpty))
      GameToyCatalogLink(
          url: link.urlController.text.trim(),
          title: link.titleController.text.trim(),
          description: link.descriptionController.text,
          kind: 'external'),
    for (final link in draft.trailers
        .where((link) => link.urlController.text.trim().isNotEmpty))
      GameToyCatalogLink(
          url: link.urlController.text.trim(),
          title: link.titleController.text.trim(),
          description: link.descriptionController.text,
          kind: 'trailer')
  ]);
  return CatalogSearchCandidate.fromItem(CatalogItemDto(
      ref: CatalogItemRef(
          kind: CatalogMediaKind.gameToy,
          id: 'manual-game_toy-${DateTime.now().microsecondsSinceEpoch}'),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal));
}

Map<String, Object?>? buildGameToyManualProposalData(LibraryKindAddDraft draft,
        {required String title}) =>
    buildGameToyManualCandidate(draft, title: title)
        ?.kindCapability
        .mapTransport((item) => Map<String, Object?>.from(item.kindData));
