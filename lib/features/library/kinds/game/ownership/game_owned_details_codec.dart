import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';

class GameOwnedDetailsCodec
    extends OwnedDetailsPersistenceCodec<GameOwnedDetails> {
  const GameOwnedDetailsCodec();

  @override
  GameOwnedDetails fromJson(Map<String, dynamic> json) =>
      GameOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(GameOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(GameOwnedDetails details) =>
      details.toJson();

  @override
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
