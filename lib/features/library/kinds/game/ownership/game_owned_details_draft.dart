import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';

class GameOwnedDetailsDraft extends OwnedDetailsDraft {
  const GameOwnedDetailsDraft({
    this.completeness,
    this.hasBox,
    this.hasManual,
    this.priceChartingId,
    this.coreRegion,
    this.valueIsLocked,
  });

  final String? completeness;
  final bool? hasBox;
  final bool? hasManual;
  final String? priceChartingId;
  final String? coreRegion;
  final bool? valueIsLocked;

  @override
  GameOwnedDetails toDetails() => GameOwnedDetails(
        completeness: completeness,
        hasBox: hasBox,
        hasManual: hasManual,
        priceChartingId: priceChartingId,
        coreRegion: coreRegion,
        valueIsLocked: valueIsLocked,
      );
}
