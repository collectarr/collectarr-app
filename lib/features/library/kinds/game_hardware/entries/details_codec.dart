import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_entry_details_draft.dart';

final class GameHardwareEntryDetailsCodec {
  const GameHardwareEntryDetailsCodec();

  GameHardwareEntryDetails fromJson(Map<String, dynamic> json) =>
      GameHardwareEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(GameHardwareEntryDetails details) =>
      details.toJson();

  Map<String, dynamic> toSyncPayload(GameHardwareEntryDetails details) =>
      details.toJson();

  GameHardwareEntryDetails defaultDetails() => const GameHardwareEntryDetails();

  GameHardwareEntryDetailsDraft draftFromDetails(
          GameHardwareEntryDetails details) =>
      GameHardwareEntryDetailsDraft(details);

  GameHardwareEntryDetailsDraft defaultDraft() =>
      const GameHardwareEntryDetailsDraft();
}
