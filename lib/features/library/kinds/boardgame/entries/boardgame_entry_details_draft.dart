import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';

class BoardgameEntryDetailsDraft implements JsonEncodable {
  const BoardgameEntryDetailsDraft({
    this.editionLanguage,
    this.editionRegion,
    this.componentCondition,
    this.componentCompleteness,
    this.missingPiecesNotes,
    this.isSleeved = false,
    this.hasCustomInsert = false,
    this.hasPaintedMiniatures = false,
    this.storageNotes,
  });

  final String? editionLanguage;
  final String? editionRegion;
  final String? componentCondition;
  final String? componentCompleteness;
  final String? missingPiecesNotes;
  final bool isSleeved;
  final bool hasCustomInsert;
  final bool hasPaintedMiniatures;
  final String? storageNotes;

  BoardgameEntryDetails toDetails() => BoardgameEntryDetails(
        editionLanguage: editionLanguage,
        editionRegion: editionRegion,
        componentCondition: componentCondition,
        componentCompleteness: componentCompleteness,
        missingPiecesNotes: missingPiecesNotes,
        isSleeved: isSleeved,
        hasCustomInsert: hasCustomInsert,
        hasPaintedMiniatures: hasPaintedMiniatures,
        storageNotes: storageNotes,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
