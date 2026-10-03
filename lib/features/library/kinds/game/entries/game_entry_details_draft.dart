import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';

class GameEntryDetailsDraft implements JsonEncodable {
  const GameEntryDetailsDraft({
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

  GameEntryDetails toDetails() => GameEntryDetails(
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
