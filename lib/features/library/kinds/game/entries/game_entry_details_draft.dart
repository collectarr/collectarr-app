import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';

class GameEntryDetailsDraft implements JsonEncodable {
  const GameEntryDetailsDraft({
    this.completeness,
    this.hasBox,
    this.hasManual,
    this.priceChartingId,
    this.valuations,
    this.coreRegion,
    this.valueIsLocked,
  });

  final String? completeness;
  final bool? hasBox;
  final bool? hasManual;
  final String? priceChartingId;
  final GameValuationSet? valuations;
  final String? coreRegion;
  final bool? valueIsLocked;

  GameEntryDetails toDetails() => GameEntryDetails(
        completeness: completeness,
        hasBox: hasBox,
        hasManual: hasManual,
        priceChartingId: priceChartingId,
        valuations: valuations,
        coreRegion: coreRegion,
        valueIsLocked: valueIsLocked,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
