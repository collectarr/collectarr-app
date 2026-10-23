import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details.dart';

/// Complete replacement value for one GameToy entry's personal details.
class GameToyEntryDetailsDraft implements JsonEncodable {
  const GameToyEntryDetailsDraft([this.details = const GameToyEntryDetails()]);

  final GameToyEntryDetails details;

  GameToyEntryDetails toDetails() => details;

  @override
  Map<String, dynamic> toJson() => details.toJson();
}
