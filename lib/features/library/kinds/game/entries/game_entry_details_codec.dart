import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';

final class GameEntryDetailsCodec {
  const GameEntryDetailsCodec();

  GameEntryDetails fromJson(Map<String, dynamic> json) =>
      GameEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(GameEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(GameEntryDetails details) =>
      details.toJson();

  GameEntryDetails defaultDetails() => const GameEntryDetails();

  GameEntryDetailsDraft draftFromDetails(GameEntryDetails details) =>
      GameEntryDetailsDraft(details);

  GameEntryDetailsDraft defaultDraft() => const GameEntryDetailsDraft();
}
