import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details_draft.dart';

final class GameToyEntryDetailsCodec {
  const GameToyEntryDetailsCodec();

  GameToyEntryDetails fromJson(Map<String, dynamic> json) =>
      GameToyEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(GameToyEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(GameToyEntryDetails details) =>
      details.toJson();

  GameToyEntryDetails defaultDetails() => const GameToyEntryDetails();

  GameToyEntryDetailsDraft draftFromDetails(GameToyEntryDetails details) =>
      GameToyEntryDetailsDraft(details);

  GameToyEntryDetailsDraft defaultDraft() => const GameToyEntryDetailsDraft();
}
