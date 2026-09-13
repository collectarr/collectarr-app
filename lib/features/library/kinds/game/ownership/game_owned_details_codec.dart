import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';

final class GameOwnedDetailsCodec {
  const GameOwnedDetailsCodec();

  GameOwnedDetails fromJson(Map<String, dynamic> json) =>
      GameOwnedDetails.fromJson(json);

  Map<String, dynamic> toJson(GameOwnedDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(GameOwnedDetails details) =>
      details.toJson();

  GameOwnedDetails defaultDetails() => const GameOwnedDetails();

  GameOwnedDetailsDraft draftFromDetails(GameOwnedDetails details) =>
      GameOwnedDetailsDraft(
        completeness: details.completeness,
        hasBox: details.hasBox,
        hasManual: details.hasManual,
        priceChartingId: details.priceChartingId,
        coreRegion: details.coreRegion,
        valueIsLocked: details.valueIsLocked,
      );

  GameOwnedDetailsDraft defaultDraft() => const GameOwnedDetailsDraft();
}
