import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_entry_details.dart';

/// Complete replacement value for one GameHardware entry's personal details.
class GameHardwareEntryDetailsDraft implements JsonEncodable {
  const GameHardwareEntryDetailsDraft(
      [this.details = const GameHardwareEntryDetails()]);

  final GameHardwareEntryDetails details;

  GameHardwareEntryDetails toDetails() => details;

  @override
  Map<String, dynamic> toJson() => details.toJson();
}
