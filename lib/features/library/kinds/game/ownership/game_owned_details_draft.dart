import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';

class GameOwnedDetailsDraft implements JsonEncodable {
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

  GameOwnedDetails toDetails() => GameOwnedDetails(
        completeness: completeness,
        hasBox: hasBox,
        hasManual: hasManual,
        priceChartingId: priceChartingId,
        coreRegion: coreRegion,
        valueIsLocked: valueIsLocked,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
