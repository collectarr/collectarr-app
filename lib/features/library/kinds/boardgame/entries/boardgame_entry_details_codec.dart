import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_draft.dart';

final class BoardgameEntryDetailsCodec {
  const BoardgameEntryDetailsCodec();

  BoardgameEntryDetails fromJson(Map<String, dynamic> json) =>
      BoardgameEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(BoardgameEntryDetails details) =>
      details.toJson();

  Map<String, dynamic> toSyncPayload(BoardgameEntryDetails details) =>
      details.toJson();

  BoardgameEntryDetails defaultDetails() => const BoardgameEntryDetails();

  BoardgameEntryDetailsDraft draftFromDetails(BoardgameEntryDetails details) =>
      BoardgameEntryDetailsDraft(
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

  BoardgameEntryDetailsDraft defaultDraft() =>
      const BoardgameEntryDetailsDraft();
}
