import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';

class MusicEntryDetailsDraft implements JsonEncodable {
  const MusicEntryDetailsDraft({
    this.media = const [],
    this.signedBy,
    this.lastCleanedDate,
    this.lastCleanedDateParts,
  });

  final List<MusicEntryDiscDetails> media;
  final String? signedBy;
  final DateTime? lastCleanedDate;
  final PartialDate? lastCleanedDateParts;

  MusicEntryDetails toDetails() => MusicEntryDetails(
        media: media,
        signedBy: signedBy,
        lastCleanedDate: lastCleanedDate,
        lastCleanedDateParts: lastCleanedDateParts,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
