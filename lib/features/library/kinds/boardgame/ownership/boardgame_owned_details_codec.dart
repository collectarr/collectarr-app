import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_draft.dart';

final class BoardgameOwnedDetailsCodec {
  const BoardgameOwnedDetailsCodec();

  BoardgameOwnedDetails fromJson(Map<String, dynamic> json) =>
      BoardgameOwnedDetails.fromJson(json);

  Map<String, dynamic> toJson(BoardgameOwnedDetails details) =>
      details.toJson();

  Map<String, dynamic> toSyncPayload(BoardgameOwnedDetails details) =>
      details.toJson();

  BoardgameOwnedDetails defaultDetails() => const BoardgameOwnedDetails();

  BoardgameOwnedDetailsDraft draftFromDetails(BoardgameOwnedDetails details) =>
      BoardgameOwnedDetailsDraft(
        editionLanguage: details.editionLanguage,
        editionRegion: details.editionRegion,
        componentCondition: details.componentCondition,
        componentCompleteness: details.componentCompleteness,
        missingPiecesNotes: details.missingPiecesNotes,
        isSleeved: details.isSleeved,
        hasCustomInsert: details.hasCustomInsert,
        hasPaintedMiniatures: details.hasPaintedMiniatures,
        storageNotes: details.storageNotes,
      );

  BoardgameOwnedDetailsDraft defaultDraft() =>
      const BoardgameOwnedDetailsDraft();
}
