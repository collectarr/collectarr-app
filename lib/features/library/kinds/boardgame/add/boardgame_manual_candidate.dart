import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildBoardgameManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! BoardgameAddManualDraft || title.trim().isEmpty) return null;
  if (boardGameAddSchema.validate?.call(draft) != null) return null;
  final id = 'manual-boardgame-${DateTime.now().microsecondsSinceEpoch}';
  final BoardGameMetadata metadata = boardGameMetadataFromManualFormValues(
    values: draft.values,
    id: id,
    title: title,
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity:
          LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.boardgame),
      kindMetadata: metadata,
    ),
  );
}
