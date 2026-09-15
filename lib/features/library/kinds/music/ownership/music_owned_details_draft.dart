import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

class MusicOwnedDetailsDraft implements JsonEncodable {
  const MusicOwnedDetailsDraft({
    this.media = const [],
    this.signedBy,
    this.lastCleanedDate,
  });

  final List<MusicOwnedMediumDetails> media;
  final String? signedBy;
  final DateTime? lastCleanedDate;

  MusicOwnedDetails toDetails() => MusicOwnedDetails(
        media: media,
        signedBy: signedBy,
        lastCleanedDate: lastCleanedDate,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
