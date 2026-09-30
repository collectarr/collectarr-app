import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

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
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.game),
      kindMetadata: metadata,
    ),
  );
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
    (item) => Map<String, Object?>.from(
      (item.kindMetadata as GameCatalogMetadata).toJson(),
    ),
  );
}
