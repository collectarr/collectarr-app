import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_draft.dart';

class BoardgameOwnedDetailsCodec extends OwnedDetailsCodec<
    BoardgameOwnedDetails, BoardgameOwnedDetailsDraft> {
  const BoardgameOwnedDetailsCodec();

  @override
  BoardgameOwnedDetails fromJson(Map<String, dynamic> json) =>
      BoardgameOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(BoardgameOwnedDetails details) =>
      details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(BoardgameOwnedDetails details) =>
      details.toJson();

  @override
  BoardgameOwnedDetails defaultDetails() => const BoardgameOwnedDetails();

  @override
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

  @override
  BoardgameOwnedDetailsDraft defaultDraft() =>
      const BoardgameOwnedDetailsDraft();

  @override
  BoardgameOwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return const BoardgameOwnedDetailsDraft();
  }
}
