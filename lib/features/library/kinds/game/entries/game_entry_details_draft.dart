import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';

/// Complete replacement value for one Game entry's personal details.
class GameEntryDetailsDraft implements JsonEncodable {
  const GameEntryDetailsDraft([this.details = const GameEntryDetails()]);

  final GameEntryDetails details;

  GameEntryDetails toDetails() => details;

  @override
  Map<String, dynamic> toJson() => details.toJson();
}
