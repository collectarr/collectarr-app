import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';

class MusicEntryDetailsDraft implements JsonEncodable {
  const MusicEntryDetailsDraft({
    this.media = const [],
    this.signedBy,
    this.lastCleanedDate,
  });

  final List<MusicEntryDiscDetails> media;
  final String? signedBy;
  final DateTime? lastCleanedDate;

  MusicEntryDetails toDetails() => MusicEntryDetails(
        media: media,
        signedBy: signedBy,
        lastCleanedDate: lastCleanedDate,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
