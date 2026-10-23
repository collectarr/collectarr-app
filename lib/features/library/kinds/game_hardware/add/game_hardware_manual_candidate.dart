import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import '../domain/game_hardware_metadata.dart';
import 'game_hardware_add_manual_draft.dart';

CatalogSearchCandidate? buildGameHardwareManualCandidate(
    LibraryKindAddDraft draft,
    {required String title}) {
  if (draft is! GameHardwareAddManualDraft || title.trim().isEmpty) return null;
  final metadata = draft.values.toMetadata(title: title, links: [
    for (final link in draft.externalLinks
        .where((link) => link.urlController.text.trim().isNotEmpty))
      GameHardwareCatalogLink(
          url: link.urlController.text.trim(),
          title: link.titleController.text.trim(),
          description: link.descriptionController.text,
          kind: 'external'),
    for (final link in draft.trailers
        .where((link) => link.urlController.text.trim().isNotEmpty))
      GameHardwareCatalogLink(
          url: link.urlController.text.trim(),
          title: link.titleController.text.trim(),
          description: link.descriptionController.text,
          kind: 'trailer')
  ]);
  return CatalogSearchCandidate.fromItem(CatalogItemDto(
      ref: CatalogItemRef(
          kind: CatalogMediaKind.gameHardware,
          id: 'manual-game_hardware-${DateTime.now().microsecondsSinceEpoch}'),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal));
}

Map<String, Object?>? buildGameHardwareManualProposalData(
        LibraryKindAddDraft draft,
        {required String title}) =>
    buildGameHardwareManualCandidate(draft, title: title)
        ?.kindCapability
        .mapTransport((item) => Map<String, Object?>.from(item.kindData));
